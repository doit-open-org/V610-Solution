# 快速上手

本文从拿到 Cove-610 开发板开始，依次完成烧录镜像、登录开发板、编译并运行第一个程序，最后介绍板端的常用设置。以下默认值对两种构建方案的镜像都适用，也都可以在各自的配置中修改。

## 准备

- Cove-610 开发板
- 两根支持数据传输的 USB Type-C 线
- Linux 或 Windows x86_64 主机
- 从 [Releases][releases] 下载的系统镜像 `cove_610-image-<版本>.zip` 和应用开发 SDK `V610-App-SDK-<版本>.tar.gz`，两者版本要一致

## 1. 连接开发板

| 接口 | 用途                                                      |
| ---- | --------------------------------------------------------- |
| USB1 | 供电；板载 CH340N 转出 UART0 串口，用于查看启动日志和登录 |
| USB2 | USB 数据：烧录、USB 网络                                  |

1. 连接 USB1，主机上会出现一个串口设备（Linux 为 `/dev/ttyUSB0` 等，Windows 为 `COM3` 等）。
2. 用串口终端打开该设备，参数为 115200 8N1。
3. 连接 USB2。

各接口的位置和引脚定义见[硬件说明](hardware.md)。

## 2. 烧录镜像

解压系统镜像，然后按[镜像烧录](burntool.md)解压烧录工具（Linux 首次使用还要安装 udev 规则，Windows 要先安装驱动），并在工具目录执行 USB 烧录命令：

```sh
./burntool-cli -u -x /path/to/image/nand_burn_table.xml
```

工具提示等待 USB 设备后，[进入 USB 烧录模式](burntool.md#进入-usb-烧录模式)。工具识别到设备后会自动开始烧录；提示成功后给开发板重新上电。

## 3. 登录开发板

系统启动后，串口终端会出现登录提示，用户 `root`，密码 `123456`。默认密码只适合开发调试，量产或接入公共网络前，请在配置中修改密码，或登录后执行 `passwd`。

镜像默认启用 USB RNDIS 网络，板端地址为 `192.168.137.2/24`。在主机上找到开发板的 USB 网卡（MAC 地址 `02:12:34:56:78:9b`），配置地址 `192.168.137.1/24`：

- Windows：在“网络连接”中找到 `Remote NDIS Compatible Device` 网卡，在 IPv4 属性中设置 IP `192.168.137.1`、子网掩码 `255.255.255.0`，网关和 DNS 留空。
- Linux：网卡名一般为 `enx02123456789b`，执行 `sudo ip addr add 192.168.137.1/24 dev enx02123456789b && sudo ip link set enx02123456789b up`。

然后通过 SSH 登录：

```sh
ssh root@192.168.137.2
```

USB 网络初始化成功后，板端会关闭 `eth0`。

## 4. 传输文件

开发板运行 dropbear SSH 服务，可以用 `scp` 传文件：

```sh
scp -O my_app root@192.168.137.2:/root/
```

dropbear 不支持 SFTP，而 OpenSSH 9.0 及以上版本的 `scp` 默认使用 SFTP，所以要加 `-O`，改用传统的 SCP 协议。

需要反复修改、调试时，也可以在主机上开启 NFS 服务，在开发板上直接挂载主机目录，免去每次拷贝：

```sh
mkdir -p /mnt/nfs
mount -t nfs -o nolock,vers=3,tcp 192.168.137.1:/path/to/export /mnt/nfs
```

`/path/to/export` 替换为主机上导出的目录，该目录要允许开发板读写。

## 5. 编译并运行第一个程序

解压应用开发 SDK，安装编译器，编译 `helloworld` 示例：

```sh
tar -xzf V610-App-SDK-<版本>.tar.gz
cd V610-App-SDK-<版本>
bash install.sh
source export.sh
hifw.py -C examples/helloworld set-target hi3516cv610
hifw.py -C examples/helloworld build -j 4
```

`install.sh` 会下载交叉编译器和模型转换工具 CANN，只需执行一次；只编译应用、不转换模型时可以加 `--skip-cann`。每次打开新的终端后都要重新执行 `source export.sh`。

把程序传到开发板上运行：

```sh
scp -O examples/helloworld/out/helloworld root@192.168.137.2:/root/
ssh root@192.168.137.2 /root/helloworld
```

输出 `helloworld example` 即表示整套流程已走通。

## 6. 体验更多示例

SDK 的 `examples/` 目录中还有以下示例，编译和部署方法与 `helloworld` 相同，具体用法见各示例的 README：

| 示例               | 内容                                                | 需要的硬件     |
| ------------------ | --------------------------------------------------- | -------------- |
| `camera_record`  | 摄像头录制 H.264 并保存 JPEG，可选 MIPI-1 或 MIPI-2 | GC4023 摄像头  |
| `lvgl_widgets`   | LVGL 界面，支持触摸                                 | LCD 与触摸屏   |
| `audio_loopback` | 麦克风到扬声器回环                                  | 麦克风、扬声器 |
| `ble_gatt`       | BLE GATT 外设，手机连接                             | 无             |
| `opencv_resize`  | OpenCV 图像缩放                                     | 无             |

目标检测、关键点检测、语音唤醒等完整应用见 [V610-Apps][apps]。

## 硬件测试

[Releases][releases] 中的系统镜像内置硬件测试命令 `board-test`，登录后即可逐项检查外设；从源码编译的镜像不包含该命令，可改用上一节的示例。

| 命令                        | 测试内容                                    | 判定方式                            |
| --------------------------- | ------------------------------------------- | ----------------------------------- |
| `board-test wifi`         | 扫描周围的 Wi-Fi 热点                       | 自动，需要接好天线                  |
| `board-test camera [1\|2]` | MIPI-1 或 MIPI-2 摄像头录制 3 秒并抓拍 JPEG | 自动                                |
| `board-test sd`           | 在 SD 卡上写入 4 MiB 并读回校验             | 自动，需要先切换到 SD 卡模式        |
| `board-test audio [秒数]` | 麦克风到扬声器回环，默认 10 秒              | 对着麦克风说话，听扬声器            |
| `board-test lcd`          | LVGL 界面，可触摸操作                       | 看屏幕显示和触摸响应，需要 LCD 模式 |

自动判定的测试结束时输出 `PASS` 或 `FAIL` 及原因。LCD 与 SD 卡的模式切换见下文。

## 常用设置

### Wi-Fi

板载 AIC8800D80 SDIO Wi-Fi/BLE。开机后会加载驱动并启动 `wlan0`，但不会自动连接网络。编辑 `/etc/wireless/wpa_supplicant.conf` 后执行：

```sh
sh /root/start_wifi.sh
```

### LCD 与 SD 卡

LCD 与 SD 卡共用一组引脚，同一时间只能使用其中一种，也可以都不用。默认使用 LCD，切换后重启生效：

```sh
sdio1-pins sd        # 使用 SD 卡
sdio1-pins lcd       # 使用 LCD 与触摸
sdio1-pins none      # 不使用 LCD 和 SD 卡
sdio1-pins           # 查看当前模式和下次启动的模式
```

旧版本镜像中命令为 `board-periph`，用法相同，但没有 `none` 模式。

SD 卡模式下插入存储卡后，可查看设备名并挂载 FAT32 分区：

```sh
ls /dev/mmcblk*
mount /dev/mmcblk0p1 /mnt    # 按实际设备名修改
```

### 应用自启动

`/etc/init.d/S40app` 用于开机自动启动用户应用。默认 `APP_PATH` 为空，不启动任何应用。修改脚本顶部的 `APP_PATH` 即可启用：

```sh
APP_PATH=/root/my_app
```

应用在后台运行，日志写入 `/tmp/<应用名>.log`。手动控制：

```sh
/etc/init.d/S40app start|stop|restart|status
```

### 启动顺序

| 脚本                      | 内容           |
| ------------------------- | -------------- |
| `S20mpp`                | 加载媒体驱动   |
| `S30lcd` / `S31touch` | LCD 和触摸驱动 |
| `S40app`                | 用户应用       |
| `S50usb_network`        | USB RNDIS 网络 |
| `S51wireless`           | Wi-Fi/BLE 驱动 |
| `S81sdk_server`         | 厂商 SDK 服务  |

## 下一步

- [Buildroot 方案构建](buildroot.md) 或 [hi_aiot_solution 方案构建](hi_aiot_solution.md)：从源码编译系统镜像
- [硬件说明](hardware.md)：接口位置与引脚定义

[releases]: https://github.com/doit-open-org/V610-Solution/releases
[apps]: https://github.com/doit-open-org/V610-Apps
