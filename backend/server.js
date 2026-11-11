
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');

const app = express();

app.use(cors());
app.use(express.json());

const {
  SUPABASE_URL,
  SUPABASE_ANON_KEY,
  SUPABASE_SERVICE_ROLE_KEY,
  PORT = 3000,
} = process.env;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error('Konfigurasi Supabase di file .env belum lengkap.');
}

// Client untuk memeriksa sesi admin.
const supabaseAuth = createClient(
  SUPABASE_URL,
  SUPABASE_ANON_KEY,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  }
);

// Client khusus backend. Jangan pernah masukkan key ini ke Flutter.
const supabaseAdmin = createClient(
  SUPABASE_URL,
  SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  }
);

// Memastikan permintaan berasal dari admin yang sudah login.
async function hanyaAdmin(req, res, next) {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({
        message: 'Token login tidak ditemukan.',
      });
    }

    const { data: authData, error: authError } =
      await supabaseAuth.auth.getUser(token);

    if (authError || !authData.user) {
      return res.status(401).json({
        message: 'Sesi login tidak valid.',
      });
    }

    const { data: admin, error: adminError } =
      await supabaseAdmin
        .from('users')
        .select('role')
        .eq('id_user', authData.user.id)
        .maybeSingle();

    if (adminError || admin?.role !== 'admin') {
      return res.status(403).json({
        message: 'Akses hanya untuk admin.',
      });
    }

    next();
  } catch (error) {
    return res.status(500).json({
      message: 'Gagal memeriksa akses admin.',
    });
  }
}

// Memastikan backend berjalan.
app.get('/', (req, res) => {
  res.json({
    message: 'Backend RUPAH berhasil berjalan.',
  });
});

// Membuat kelas sekaligus akun login.
app.post('/api/kelas', hanyaAdmin, async (req, res) => {
  const {
    namaKelas,
    jurusan,
    namaWaliKelas,
    username,
    password,
  } = req.body;

  if (
    !namaKelas ||
    !jurusan ||
    !namaWaliKelas ||
    !username ||
    !password
  ) {
    return res.status(400).json({
      message: 'Semua data wajib diisi.',
    });
  }

  const usernameBersih = String(username).trim().toLowerCase();

  if (!/^[a-z0-9_]{3,30}$/.test(usernameBersih)) {
    return res.status(400).json({
      message: 'Username harus 3–30 karakter, hanya huruf, angka, dan underscore.',
    });
  }

  if (String(password).length < 8) {
    return res.status(400).json({
      message: 'Password minimal 8 karakter.',
    });
  }

  // Email internal yang dibentuk dari username.
  const emailLogin = `${usernameBersih}@rupah.local`;

  let idKelas;
  let idUser;

  try {
    // 1. Membuat data kelas.
    const { data: kelas, error: kelasError } =
      await supabaseAdmin
        .from('kelas')
        .insert({
          nama_kelas: String(namaKelas).trim(),
          jurusan: String(jurusan).trim(),
          nama_wali_kelas: String(namaWaliKelas).trim(),
          status: 'aktif',
        })
        .select()
        .single();

    if (kelasError) throw kelasError;

    idKelas = kelas.id_kelas;

    // 2. Membuat akun Supabase Auth.
    const { data: authData, error: authError } =
      await supabaseAdmin.auth.admin.createUser({
        email: emailLogin,
        password: String(password),
        email_confirm: true,
      });

    if (authError) throw authError;

    idUser = authData.user.id;

    // 3. Menghubungkan akun dengan kelas.
    const { error: userError } = await supabaseAdmin
      .from('users')
      .insert({
        id_user: idUser,
        username: usernameBersih,
        email: emailLogin,
        role: 'user',
        id_kelas: idKelas,
      });

    if (userError) throw userError;

    return res.status(201).json({
      message: 'Kelas dan akun berhasil dibuat.',
      data: {
        id_kelas: idKelas,
        nama_kelas: kelas.nama_kelas,
        username: usernameBersih,
      },
    });
  } catch (error) {
    // Membersihkan data jika salah satu proses gagal.
    if (idUser) {
      await supabaseAdmin.auth.admin.deleteUser(idUser);
    }

    if (idKelas) {
      await supabaseAdmin
        .from('kelas')
        .delete()
        .eq('id_kelas', idKelas);
    }

    console.error('Gagal membuat kelas:', error);

    return res.status(500).json({
      message: error.message || 'Gagal membuat kelas dan akun.',
    });
  }
});
app.post('/api/auth/username-email', async (req, res) => {
  try {
    const username = req.body.username?.trim().toLowerCase();

    if (!username) {
      return res.status(400).json({
        message: 'Username wajib diisi.',
      });
    }

    const { data, error } = await supabaseAdmin
      .from('users')
      .select('email')
      .eq('username', username)
      .maybeSingle();

    if (error) throw error;

    if (!data || !data.email) {
      return res.status(404).json({
        message: 'Username atau password salah.',
      });
    }

    return res.status(200).json({
      email: data.email,
    });
  } catch (error) {
    console.error('Gagal mencari username:', error);

    return res.status(500).json({
      message: 'Terjadi kesalahan pada server.',
    });
  }
});
app.listen(PORT, () => {
  console.log(`Backend RUPAH berjalan di http://localhost:${PORT}`);
});
