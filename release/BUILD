package(default_visibility = ["//visibility:public"])

load("//infra/bazel:zip.bzl", "pkg_zip")
load("//release:mapping.bzl", "gen_mappings")

filegroup(
    name = "config_json",
    srcs = [
        "config/config.json",
        "config/vpoint_socks_vmess.json",
        "config/vpoint_vmess_freedom.json",
    ],
)

filegroup(
    name = "systemd",
    srcs = [
        "config/systemd/tutacc.service",
        "config/systemv/tutacc",
    ],
)

filegroup(
    name = "doc",
    srcs = glob(["doc/*.md"]),
)

filegroup(
    name = "geodata",
    srcs = [
        "config/geoip.dat",
        "config/geosite.dat",
    ],
)

pkg_zip(
    name = "tutacc_darwin_amd64_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        "//infra/control/main:tutactl_darwin_amd64",
        "//infra/control/main:tutactl_darwin_amd64_sig",
        "//main:tutacc_darwin_amd64",
        "//main:tutacc_darwin_amd64_sig",
    ],
    out = "tutacc-macos.zip",
    mappings = gen_mappings("darwin", "amd64"),
)

pkg_zip(
    name = "tutacc_windows_amd64_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        "//infra/control/main:tutactl_windows_amd64",
        "//infra/control/main:tutactl_windows_amd64_sig",
        "//main:tutacc_windows_amd64",
        "//main:tutacc_windows_amd64_nowindow",
        "//main:tutacc_windows_amd64_nowindow_sig",
        "//main:tutacc_windows_amd64_sig",
    ],
    out = "tutacc-windows-64.zip",
    mappings = gen_mappings("windows", "amd64"),
)

pkg_zip(
    name = "tutacc_windows_x86_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        "//infra/control/main:tutactl_windows_386",
        "//infra/control/main:tutactl_windows_386_sig",
        "//main:tutacc_windows_386",
        "//main:tutacc_windows_386_nowindow",
        "//main:tutacc_windows_386_nowindow_sig",
        "//main:tutacc_windows_386_sig",
    ],
    out = "tutacc-windows-32.zip",
    mappings = gen_mappings("windows", "386"),
)

pkg_zip(
    name = "tutacc_freebsd_amd64_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        "//infra/control/main:tutactl_freebsd_amd64",
        "//infra/control/main:tutactl_freebsd_amd64_sig",
        "//main:tutacc_freebsd_amd64",
        "//main:tutacc_freebsd_amd64_sig",
    ],
    out = "tutacc-freebsd-64.zip",
    mappings = gen_mappings("freebsd", "amd64"),
)

pkg_zip(
    name = "tutacc_freebsd_x86_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        "//infra/control/main:tutactl_freebsd_386",
        "//infra/control/main:tutactl_freebsd_386_sig",
        "//main:tutacc_freebsd_386",
        "//main:tutacc_freebsd_386_sig",
    ],
    out = "tutacc-freebsd-32.zip",
    mappings = gen_mappings("freebsd", "386"),
)

pkg_zip(
    name = "tutacc_openbsd_amd64_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        "//infra/control/main:tutactl_openbsd_amd64",
        "//infra/control/main:tutactl_openbsd_amd64_sig",
        "//main:tutacc_openbsd_amd64",
        "//main:tutacc_openbsd_amd64_sig",
    ],
    out = "tutacc-openbsd-64.zip",
    mappings = gen_mappings("openbsd", "amd64"),
)

pkg_zip(
    name = "tutacc_openbsd_x86_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        "//infra/control/main:tutactl_openbsd_386",
        "//infra/control/main:tutactl_openbsd_386_sig",
        "//main:tutacc_openbsd_386",
        "//main:tutacc_openbsd_386_sig",
    ],
    out = "tutacc-openbsd-32.zip",
    mappings = gen_mappings("openbsd", "386"),
)

pkg_zip(
    name = "tutacc_dragonfly_amd64_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        "//infra/control/main:tutactl_dragonfly_amd64",
        "//infra/control/main:tutactl_dragonfly_amd64_sig",
        "//main:tutacc_dragonfly_amd64",
        "//main:tutacc_dragonfly_amd64_sig",
    ],
    out = "tutacc-dragonfly-64.zip",
    mappings = gen_mappings("dragonfly", "amd64"),
)

pkg_zip(
    name = "tutacc_linux_amd64_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_amd64",
        "//infra/control/main:tutactl_linux_amd64_sig",
        "//main:tutacc_linux_amd64",
        "//main:tutacc_linux_amd64_sig",
    ],
    out = "tutacc-linux-64.zip",
    mappings = gen_mappings("linux", "amd64"),
)

pkg_zip(
    name = "tutacc_linux_x86_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_386",
        "//infra/control/main:tutactl_linux_386_sig",
        "//main:tutacc_linux_386",
        "//main:tutacc_linux_386_sig",
    ],
    out = "tutacc-linux-32.zip",
    mappings = gen_mappings("linux", "386"),
)

pkg_zip(
    name = "tutacc_linux_arm_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_arm",
        "//infra/control/main:tutactl_linux_arm_armv7",
        "//infra/control/main:tutactl_linux_arm_armv7_sig",
        "//infra/control/main:tutactl_linux_arm_sig",
        "//main:tutacc_linux_arm",
        "//main:tutacc_linux_arm_armv6",
        "//main:tutacc_linux_arm_armv6_sig",
        "//main:tutacc_linux_arm_armv7",
        "//main:tutacc_linux_arm_armv7_sig",
        "//main:tutacc_linux_arm_sig",
    ],
    out = "tutacc-linux-arm.zip",
    mappings = gen_mappings("linux", "arm"),
)

pkg_zip(
    name = "tutacc_linux_arm64_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_arm64",
        "//infra/control/main:tutactl_linux_arm64_sig",
        "//main:tutacc_linux_arm64",
        "//main:tutacc_linux_arm64_sig",
    ],
    out = "tutacc-linux-arm64.zip",
    mappings = gen_mappings("linux", "arm64"),
)

pkg_zip(
    name = "tutacc_linux_mips_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_mips",
        "//infra/control/main:tutactl_linux_mips_sig",
        "//infra/control/main:tutactl_linux_mips_softfloat",
        "//infra/control/main:tutactl_linux_mips_softfloat_sig",
        "//main:tutacc_linux_mips",
        "//main:tutacc_linux_mips_sig",
        "//main:tutacc_linux_mips_softfloat",
        "//main:tutacc_linux_mips_softfloat_sig",
    ],
    out = "tutacc-linux-mips.zip",
    mappings = gen_mappings("linux", "mips"),
)

pkg_zip(
    name = "tutacc_linux_mipsle_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_mipsle",
        "//infra/control/main:tutactl_linux_mipsle_sig",
        "//infra/control/main:tutactl_linux_mipsle_softfloat",
        "//infra/control/main:tutactl_linux_mipsle_softfloat_sig",
        "//main:tutacc_linux_mipsle",
        "//main:tutacc_linux_mipsle_sig",
        "//main:tutacc_linux_mipsle_softfloat",
        "//main:tutacc_linux_mipsle_softfloat_sig",
    ],
    out = "tutacc-linux-mipsle.zip",
    mappings = gen_mappings("linux", "mipsle"),
)

pkg_zip(
    name = "tutacc_linux_mips64_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_mips64",
        "//infra/control/main:tutactl_linux_mips64_sig",
        "//main:tutacc_linux_mips64",
        "//main:tutacc_linux_mips64_sig",
    ],
    out = "tutacc-linux-mips64.zip",
    mappings = gen_mappings("linux", "mips64"),
)

pkg_zip(
    name = "tutacc_linux_mips64le_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_mips64le",
        "//infra/control/main:tutactl_linux_mips64le_sig",
        "//main:tutacc_linux_mips64le",
        "//main:tutacc_linux_mips64le_sig",
    ],
    out = "tutacc-linux-mips64le.zip",
    mappings = gen_mappings("linux", "mips64le"),
)

pkg_zip(
    name = "tutacc_linux_s390x_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_s390x",
        "//infra/control/main:tutactl_linux_s390x_sig",
        "//main:tutacc_linux_s390x",
        "//main:tutacc_linux_s390x_sig",
    ],
    out = "tutacc-linux-s390x.zip",
    mappings = gen_mappings("linux", "s390x"),
)

pkg_zip(
    name = "tutacc_linux_ppc64_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_ppc64",
        "//infra/control/main:tutactl_linux_ppc64_sig",
        "//main:tutacc_linux_ppc64",
        "//main:tutacc_linux_ppc64_sig",
    ],
    out = "tutacc-linux-ppc64.zip",
    mappings = gen_mappings("linux", "ppc64"),
)

pkg_zip(
    name = "tutacc_linux_ppc64le_package",
    srcs = [
        ":config_json",
        ":doc",
        ":geodata",
        ":systemd",
        "//infra/control/main:tutactl_linux_ppc64le",
        "//infra/control/main:tutactl_linux_ppc64le_sig",
        "//main:tutacc_linux_ppc64le",
        "//main:tutacc_linux_ppc64le_sig",
    ],
    out = "tutacc-linux-ppc64le.zip",
    mappings = gen_mappings("linux", "ppc64le"),
)
