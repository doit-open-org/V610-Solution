# 镜像烧录

Cove-610 使用 `burntool-cli` 烧录镜像，支持 Linux 和 Windows x86_64。`burntool-cli` 由四博智联基于海思官方烧录工具精简适配，位于本仓库的 [`tools/burntool-cli/`](../tools/burntool-cli/) 目录。

烧录会擦除并改写 NAND 中选定的分区。烧录过程中不要断开 USB、串口或板卡电源。

## 镜像来源

烧录时通过 `-x` 指定 `nand_burn_table.xml`，镜像文件与它放在同一目录：

| 来源 | 目录 |
| --- | --- |
| 预编译镜像 | 解压 `cove_610-image-<版本>.zip` 得到的目录 |
| Buildroot 方案 | `V610-Buildroot/output/images/flash/` |
| hi_aiot_solution 方案 | `hi_aiot_solution/_build/install/image/base_image/` |

XML 和其中引用的镜像必须来自同一次构建。

默认分区：

| 分区 | 起始地址 | 分区大小 | 文件 |
| --- | ---: | ---: | --- |
| `boot` | `0x000000` | `0x080000` | `boot_image.bin` |
| `env` | `0x080000` | `0x080000` | `nand_env.bin` |
| `kernel` | `0x100000` | `0x400000` | `uImage` |
| `rootfs` | `0x500000` | `0x3b00000` | `rootfs_hi3516cv610_2k_128k_59M.ubifs` |

## Linux

解压工具：

```sh
cd tools/burntool-cli
unzip burntool-cli-linux-5.6.48-x86_64.zip
cd burntool-cli-linux-5.6.48-x86_64
```

首次使用 USB 烧录前安装 udev 规则，然后重新插拔板卡：

```sh
sudo install -m 0644 99-burntool-cli.rules /etc/udev/rules.d/99-burntool-cli.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

USB BootROM 烧录：执行以下命令，工具提示等待 USB 设备后[进入 USB 烧录模式](#进入-usb-烧录模式)：

```sh
./burntool-cli -u -x /path/to/image/nand_burn_table.xml
```

串口烧录（当前用户需要有串口读写权限）：

```sh
./burntool-cli -s /dev/ttyUSB0 -x /path/to/image/nand_burn_table.xml
```

## Windows

1. 解压 `tools/burntool-cli/burntool-cli-windows-5.6.48-x86_64.zip`，建议放在纯英文路径下。
2. USB 烧录前运行 `tools/USBBurnDriver.exe` 安装驱动。

USB BootROM 烧录，工具提示等待 USB 设备后[进入 USB 烧录模式](#进入-usb-烧录模式)：

```powershell
.\burntool-cli.exe -u -x C:\Cove-610\image\nand_burn_table.xml
```

串口烧录，在设备管理器中确认串口号后执行：

```powershell
.\burntool-cli.exe -s COM3 -x C:\Cove-610\image\nand_burn_table.xml
```

## 进入 USB 烧录模式

USB1 负责供电和串口，USB2 连接烧录主机。先启动烧录命令，再按以下步骤操作：

1. 按住 `UPDATE` 键不放。
2. 拔掉 USB1 再插上，让开发板重新上电，USB2 保持连接。
3. 烧录工具识别到设备并开始烧录后，松开 `UPDATE`。

如果开发板直接进入了 Linux，而工具还在等待设备，检查 USB2 数据线和驱动，然后重新执行上述步骤。

## 只烧录部分分区

```sh
./burntool-cli -u -x /path/to/image/nand_burn_table.xml --part kernel,rootfs
```

不指定 `--part` 时，烧录 XML 中所有 `Sel="1"` 的分区。升级完整系统或分区布局有变化时，应执行全量烧录。

## 常用参数

| 参数 | 说明 |
| --- | --- |
| `-u` | USB BootROM 模式 |
| `-s DEVICE` | 串口模式，如 `/dev/ttyUSB0` 或 `COM3` |
| `-x FILE` | 烧录分区 XML，必填 |
| `-n CHIP` | 芯片型号，默认 `Hi3516CV610` |
| `-b BAUD` | 串口波特率，默认 `115200` |
| `--part NAME,...` | 只烧录指定分区 |
| `--usb-vid ID` / `--usb-pid ID` | 覆盖 USB VID / PID |
| `--version` | 显示工具版本 |

## 常见问题

| 现象 | 检查项 |
| --- | --- |
| USB 模式找不到设备 | 确认板卡已进入 BootROM 模式；重新插拔 USB；Linux 下检查 udev 规则，Windows 下检查驱动 |
| 串口无法打开 | 确认设备名或 COM 号；关闭占用串口的终端；检查用户权限 |
| 找不到镜像文件 | 确认 XML 和镜像文件在同一目录 |
| 分区或镜像大小错误 | 使用同一次构建生成的 XML 和镜像，执行全量烧录 |
| 烧录中断 | 保持板卡供电，重新进入烧录模式后全量烧录 |
