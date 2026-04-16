FROM scratch

# Copy seluruh rootfs Spark-OS
COPY rootfs/ /

# Spark-OS metadata
LABEL maintainer="Spark-OS"
LABEL version="1.0"
LABEL description="Spark OS - Mini Linux Environment"

# Port yang umum digunakan (opsional, untuk dokumentasi)
# EXPOSE 22 80 443

# Jalankan login shell saat container start
CMD ["/bin/sh", "-c", "source /etc/profile && exec /bin/sh"]
