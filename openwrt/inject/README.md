# Tutorial install

## Untuk Xderm

Download semua file yanga ada di folder ini

Pindah xderm-ini ke /etc/init.d/
```bash
mv xderm-init /etc/init.d/xderm
```

Kasih permissions ke file xderm-init tadi
```bash
chmod +x /etc/init.d/xderm
```

Kasih permissions juga ke file inet-check.sh
```bash
chmod +x inet-check.sh
```

Lalu buat screen/session untuk script ping/inet checker
> Nama boleh sesuka hati
```bash
screen -S <nama>
```

Lalu jalan kan script inet-check.sh
```bash
./inet-check.sh
```

Done

### Selain xderm bisa di ubah di bagian inet-check.sh nya saja, di sesuaikan dengan selera
