# V610-Solution

V610-Solution 是 V610 系列模组和 Cove-610 开发板的软件解决方案，提供板级适配、系统镜像、应用开发 SDK、应用示例以及烧录工具。

V610 系列模组由四博智联基于海思 Hi3516CV610 SoC 设计，Cove-610 是基于该模组的开发板。

## 软件支持

- Linux 5.10 内核，SPI NAND 启动，UBIFS 根文件系统
- 海思 MPP 媒体框架与 SVP 推理运行环境
- 摄像头 sensor：GC4023、OS04D10、SC431HAI、SC4336P、SC450AI、SC500AI
- AIC8800D80 SDIO Wi-Fi / BLE
- USB RNDIS 网络与 SSH 登录
- SPI LCD（ST7789V、NV3041A）及电容触摸（FT6336U、GT911）
- 应用开发框架 HiFW，提供媒体管线、模型推理、LVGL 图形界面等组件

## 快速开始

使用预编译镜像，无需搭建编译环境：

1. 在 [Releases][releases] 下载系统镜像 `cove_610-image-<版本>.zip`。烧录工具位于本仓库的 [`tools/`](tools/) 目录。
2. 按照[镜像烧录](docs/burntool.md)将镜像烧录到开发板。
3. 通过串口或 USB 网络登录开发板。

从接线、烧录到编译运行第一个程序的完整步骤，以及 Wi-Fi、SD 卡、应用自启动等板端设置，见[快速上手](docs/quickstart.md)。

## 从源码构建

提供两种系统构建方案。两者基于同一版本的厂商 SDK、交叉编译器和 NAND 分区布局，生成的镜像使用相同的方式烧录。

| | V610-Buildroot | hi_aiot_solution |
| --- | --- | --- |
| 构建系统 | Buildroot 2026.02 | CMake + Kconfig（海思 HiSpark 框架） |
| 厂商 SDK | Hi3516CV610 tag_V2.1.0_Beta | Hi3516CV610 tag_V2.1.0_Beta |
| 应用开发 | 独立的 V610-App-SDK 发布包 | 在源码树内构建，可使用 HiSpark 组件和案例 |
| 推荐场景 | 定制和裁剪系统、长期维护的产品镜像 | 基于 HiSpark 组件和 AI 案例快速开发 |
| 构建说明 | [Buildroot 方案](docs/buildroot.md) | [hi_aiot_solution 方案](docs/hi_aiot_solution.md) |

## 应用开发

[V610-App-SDK][app_sdk] 是应用开发 SDK，基于 CMake 和 Kconfig，提供媒体、推理和图形界面组件；[V610-Apps][apps] 提供目标检测、关键点检测、语音唤醒等完整应用示例。

应用 SDK 发布包可在 [Releases][releases] 下载，需与同版本的系统镜像配套使用。使用方法见 V610-App-SDK 的 README。

## 下载

系统镜像和应用 SDK 随版本发布在 [Releases][releases]：

| 文件 | 说明 |
| --- | --- |
| `cove_610-image-<版本>.zip` | 系统镜像 |
| `V610-App-SDK-<版本>.tar.gz` | 应用开发 SDK |
| `SHA256SUMS` | SHA-256 校验值 |

下载后可校验文件完整性：

```sh
sha256sum -c SHA256SUMS --ignore-missing
```

烧录工具位于本仓库的 `tools/` 目录：

| 文件 | 说明 |
| --- | --- |
| `tools/burntool-cli/burntool-cli-linux-5.6.48-x86_64.zip` | Linux 烧录工具 |
| `tools/burntool-cli/burntool-cli-windows-5.6.48-x86_64.zip` | Windows 烧录工具 |
| `tools/USBBurnDriver.exe` | Windows USB 烧录驱动 |

## 相关仓库

| 仓库 | 说明 |
| --- | --- |
| [V610-Buildroot][buildroot] | Buildroot 系统构建工程 |
| [hi_aiot_solution][hi_aiot_solution] | 基于海思 HiSpark hi_aiot_solution 的 Cove-610 适配 |
| [V610-App-SDK][app_sdk] | 应用开发 SDK |
| [V610-Apps][apps] | 应用示例 |

## 文档

| 文档 | 内容 |
| --- | --- |
| [快速上手](docs/quickstart.md) | 接线、烧录、登录、文件传输、第一个程序、板端常用设置 |
| [Buildroot 方案构建](docs/buildroot.md) | 编译镜像、修改配置、生成应用 SDK |
| [hi_aiot_solution 方案构建](docs/hi_aiot_solution.md) | 安装环境、编译镜像、构建应用 |
| [镜像烧录](docs/burntool.md) | Linux / Windows 下的 USB 和串口烧录 |
| [硬件说明](docs/hardware.md) | 板载组件、功能框图、各连接器引脚定义 |
| [Cove-610 原理图](hardware/Cove-610_V1.1.pdf) | 开发板原理图 |

## 许可证

本仓库内容采用 [Apache License 2.0](LICENSE) 许可。各源码仓库的许可证见其仓库中的 LICENSE 文件；海思 SDK、交叉编译器和烧录工具遵循海思的发布许可。

[releases]: https://github.com/doit-open-org/V610-Solution/releases
[buildroot]: https://github.com/doit-open-org/V610-Buildroot
[hi_aiot_solution]: https://github.com/doit-open-org/hi_aiot_solution
[app_sdk]: https://github.com/doit-open-org/V610-App-SDK
[apps]: https://github.com/doit-open-org/V610-Apps
