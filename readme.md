
# Final Project PSD BP08 - Image-ColorScaler

## Background
Gambar berwarna dapat digunakan untuk berbagai keperluan, seperti untuk keperluan estetika, untuk keperluan informasi, atau untuk keperluan penelitian. Namun, terkadang gambar berwarna dapat menjadi terlalu kompleks atau rumit untuk diproses atau ditampilkan. Dalam hal ini, gambar berwarna dapat diubah menjadi grayscale untuk mempermudah proses atau tampilannya.

Grayscale merupakan representasi gambar dengan menggunakan satu dimensi warna, yaitu intensitas cahaya. Gambar grayscale dapat digunakan untuk menghemat ruang penyimpanan, untuk mempermudah proses pengolahan citra, atau untuk memberikan efek tertentu pada gambar.

Proyek Image-ColorScaler ini bertujuan untuk membangun sistem digital yang dapat mengubah gambar berwarna menjadi grayscale. Sistem ini dibangun menggunakan bahasa VHDL dan diimplementasikan pada FPGA.

## How it works
Sistem Image-ColorScaler ini bekerja dengan cara membaca file gambar berwarna dalam format .bmp. File gambar .bmp merupakan format gambar yang umum digunakan dan didukung oleh berbagai perangkat lunak. File gambar .bmp terdiri dari header yang berisi informasi tentang ukuran, resolusi, dan format gambar, serta data gambar yang berisi nilai-nilai pixel gambar.

Sistem Image-ColorScaler ini membaca header file gambar untuk mendapatkan informasi tentang ukuran dan resolusi gambar. Informasi ini kemudian digunakan untuk menginisialisasi memori yang akan digunakan untuk menyimpan data gambar.

Data gambar kemudian dibaca dan diproses untuk mengubahnya menjadi grayscale. Data gambar grayscale kemudian disimpan kembali ke memori. File gambar grayscale kemudian dapat ditulis ke disk. File gambar .bmp merupakan format gambar yang umum digunakan dan didukung oleh berbagai perangkat lunak. Format gambar .bmp memiliki struktur yang sederhana dan mudah untuk diimplementasikan dalam bahasa VHDL.

Format gambar lain, seperti file gambar .jpg atau .png, memiliki struktur yang lebih kompleks dan sulit untuk diimplementasikan dalam bahasa VHDL. Selain itu, format gambar lain juga sering menggunakan kompresi, yang dapat menyulitkan proses dekompresi dalam bahasa VHDL. Oleh karena itu, dalam proyek ini hanya file gambar .bmp yang digunakan.

## How to use
| OPCODE | Keterangan |
| --- | --- |
| `000000` | Mengubah gambar menjadi grayscale |
| `000001` | Mengubah gambar menjadi greenscale, grayscale tapi dengan tone hijau |
| `000010` | Mengubah gambar menjadi redscale, grayscale tapi dengan tone red |
| `000011` | Mengubah gambar menjadi bluescale, grayscale tapi dengan tone biru |

Pada program VHDL yang sudah ada, masukan `INSTRUCTION_IN` yang berisi `OPCODE` yang sesuai. Apabial `OPCODE` tidak tertera pada table, maka program otomatis akan langsung melakukan copy dari source file ke destination file

## Testing
Kita melakukan testing terhadap program yang telah kita buat, untuk hasil testing selengkapnya dapat dilihat pada laporan proyek akhir
## Authors

- [@MorpKnight](https://www.github.com/MorpKnight)
- [@annisa-ardelia](https://www.github.com/annisa-ardelia)
- [@GeraldoGio](https://github.com/GeraldoGio)
- [@arifatalya](https://github.com/arifatalya)

