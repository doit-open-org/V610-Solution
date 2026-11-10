# Buildroot 方案构建

[V610-Buildroot](https://github.com/doit-open-org/V610-Buildroot) 是基于 Buildroot 的 Cove-610 镜像工程，集成 Hi3516CV610 厂商内核、U-Boot、MPP、无线模块和板级驱动。

| 项目 | 版本 |
| --- | --- |
| Buildroot | 2026.02.3 |
| 厂商 SDK | Hi3516CV610 tag_V2.1.0_Beta |
| Linux | 5.10.221 |
| 编译器 | GCC 10.3 / musl，ARM softfp |

## 环境要求

- Linux x86_64，或 WSL2
- 构建路径中不能有空格
- 首次构建需要访问 gitcode.com 和 buildroot.org，下载约 2.5 GB 厂商源码
- 预留 15 GB 以上磁盘空间

## 构建镜像

```sh
git clone https://github.com/doit-open-org/V610-Buildroot.git
cd V610-Buildroot
bash install.sh
make cove_610_defconfig
make
```

`make` 首次执行时会下载 Buildroot，并通过 `scripts/fetch-vendor.sh` 从 [HiSpark/Hi3516CV610](https://gitcode.com/HiSpark/Hi3516CV610) 拉取厂商 SDK、内核源码和编译器到 `vendor/`。下载缓存保存在 `dl/`，离线构建时需要备齐这两个目录。

烧录文件输出到 `output/images/flash/`：

```text
boot_image.bin
nand_burn_table.xml
nand_env.bin
nand_env.txt
rootfs_hi3516cv610_2k_128k_59M.ubifs
uImage
```

烧录方法见[镜像烧录](burntool.md)。

## 修改配置

```sh
make menuconfig          # Buildroot 配置
make linux-menuconfig    # 内核配置
make savedefconfig       # 保存 Buildroot 配置到 configs/cove_610_defconfig
```

修改某个软件包后重新编译该包，再执行 `make` 重新生成镜像：

```sh
make linux-rebuild
make hisi-osdrv-rebuild
make
```

板级文件位置：

| 路径 | 用途 |
| --- | --- |
| `configs/cove_610_defconfig` | Buildroot 默认配置 |
| `board/cove_610/linux.config` | 内核配置 |
| `board/cove_610/dts/` | 设备树 |
| `board/cove_610/flash.cfg` | NAND 分区大小 |
| `board/cove_610/rootfs_overlay/` | 根文件系统覆盖文件和启动脚本 |
| `package/` | 厂商及板级软件包 |

修改分区时，需要同时调整 `board/cove_610/flash.cfg`、defconfig 中的 UBIFS 容量和启动配置。

## 生成应用 SDK

将 [V610-App-SDK](https://github.com/doit-open-org/V610-App-SDK) 克隆到工程根目录后执行：

```sh
git clone https://github.com/doit-open-org/V610-App-SDK.git
make app-sdk
```

发布包输出到 `V610-App-SDK/dist/V610-App-SDK-<版本>.tar.gz`，其中的头文件和库与本次构建的镜像一致。板端系统库更新后，需要重新生成应用 SDK。

应用开发方法见 V610-App-SDK 仓库的 README。
