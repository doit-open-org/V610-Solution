# hi_aiot_solution 方案构建

[hi_aiot_solution](https://github.com/doit-open-org/hi_aiot_solution) 基于海思 [HiSpark hi_aiot_solution](https://gitcode.com/HiSpark/hi_aiot_solution)，增加了 Cove-610 板级支持，构建目标为 `cove_610`。它同时提供 HiSpark 的适配层、媒体、网络和 AI 组件。

## 环境要求

- Linux x86_64，或 WSL2
- 安装 `git-lfs`：仓库内置的精简 SDK 包使用 Git LFS 存放
- 可访问 gitcode.com，下载编译器和 CANN

## 获取源码

```sh
git lfs install
git clone --recurse-submodules https://github.com/doit-open-org/hi_aiot_solution.git
cd hi_aiot_solution
```

子模块 `apps/cove_610/V610-App-SDK` 和 `apps/cove_610/V610-Apps` 只用于应用开发，只构建镜像时可以不拉取。

## 安装构建环境

```sh
bash install.sh
source export.sh
```

`install.sh` 安装主机软件包，并将交叉编译器和 CANN 下载到 `toolchain/` 和 `CANN/`。指定其他目录：

```sh
bash install.sh --toolchain-dir /path/to/toolchain --cann-dir /path/to/CANN
```

打开新终端后，需要在仓库根目录重新执行 `source export.sh`。

## 构建基础镜像

```sh
bash scripts/build.sh build --target cove_610 references base_image
```

烧录文件输出到 `_build/install/image/base_image/`：

```text
boot_image.bin
nand_burn_table.xml
nand_env.bin
rootfs_hi3516cv610_2k_128k_59M.ubifs
uImage
```

烧录方法见[镜像烧录](burntool.md)。

## 修改配置

```sh
bash apps/cove_610/references/base_image/menuconfig.sh
bash scripts/build.sh build
```

常用配置项包括 rootfs 分区大小、root 密码、USB 网络、Wi-Fi/BLE、LCD 面板和触摸控制器，详见源码中的 `apps/cove_610/references/base_image/README.md`。

## 应用开发

V610-App-SDK 依赖本工程编出的厂商 SDK，需要先完成一次基础镜像构建。

构建 V610-Apps 中的应用：

```sh
bash apps/cove_610/samples/v610_apps/build.sh                         # 全部应用
bash apps/cove_610/samples/v610_apps/build.sh mipk_object_detection   # 指定应用
```

构建 SDK 示例：

```sh
source apps/cove_610/V610-App-SDK/export.sh
cd apps/cove_610/V610-App-SDK/examples/helloworld
hifw.py set-target hi3516cv610
hifw.py build
```

HiSpark 框架本身的构建系统、组件和案例说明见源码中的 `docs/`。
