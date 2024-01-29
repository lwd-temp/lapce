variable "RUST_VERSION" {
  default = "1.75"
}

variable "PACKAGE_NAME" {
  default = "lapce-nightly"
}

variable "PACKAGE_VERSION" {
  default = "nightly"
}

variable "RELEASE_TAG_NAME" {
  default = ""
}

target "_common" {
  args = {
    PACKAGE_NAME    = PACKAGE_NAME
    PACKAGE_VERSION = PACKAGE_VERSION

    RUST_VERSION = RUST_VERSION

    RELEASE_TAG_NAME = RELEASE_TAG_NAME

    BUILDKIT_CONTEXT_KEEP_GIT_DIR = 1

    OUTPUT_DIR = "/output"
  }
}

target "_platforms" {
  platforms = [
    "linux/amd64",
    // "linux/arm/v6",
    // "linux/arm/v7",
    "linux/arm64",
    // "linux/ppc64le",
    // "linux/riscv64",
    // "linux/s390x",
  ]
}

group "default" {
  targets = ["binary"]
}

target "binary" {
  inherits  = ["_common"]
  target    = "binary"
  platforms = ["local"]
  output    = ["target"]
}

target "cross-binary" {
  inherits = ["binary", "_platforms"]
}

// OS

variable "DEBIAN_FAMILY_PACKAGES" {
  default = [
    "libc6-dev",
    "libssl-dev",
    "zlib1g-dev",
    "libzstd-dev",
    "libvulkan-dev",
    "libwayland-dev",
    "libxcb-shape0-dev",
    "libxcb-xfixes0-dev",
    "libxkbcommon-x11-dev",
  ]
}

target "debian" {
  inherits   = ["cross-binary"]
  name       = "${distro}-${build.os_version}"
  target     = "cross-binary"
  context    = "."
  dockerfile = "extra/linux/docker/${distro}/Dockerfile"
  output     = ["target/${distro}/${build.os_version}"]
  args = {
    DISTRIBUTION_NAME     = distro
    DISTRIBUTION_VERSION  = build.os_version
    DISTRIBUTION_PACKAGES = join(" ", build.packages)
  }
  matrix = {
    distro = ["debian"]
    build = [
      // {
      //   os_version = "buster"
      //   packages = [
      //     "libc6-dev",
      //     "libssl-dev",
      //     "zlib1g-dev",
      //     "libzstd-dev",
      //     "libvulkan-dev",
      //     "libwayland-dev",
      //     "libxcb-shape0-dev",
      //     "libxcb-xfixes0-dev",
      //     "libxkbcommon-x11-dev",
      //   ]
      // },
      {
        os_version = "bullseye"
        packages   = DEBIAN_FAMILY_PACKAGES
      },
      {
        os_version = "bookworm"
        packages   = DEBIAN_FAMILY_PACKAGES
      },
    ]
  }
}

target "ubuntu" {
  inherits   = ["cross-binary"]
  name       = "${distro}-${build.os_version}"
  target     = "cross-binary"
  context    = "."
  dockerfile = "extra/linux/docker/${distro}/Dockerfile"
  output     = ["target/${distro}/${build.os_version}"]
  args = {
    DISTRIBUTION_NAME     = distro
    DISTRIBUTION_VERSION  = build.os_version
    DISTRIBUTION_PACKAGES = join(" ", build.packages)
  }
  matrix = {
    distro = ["ubuntu"]
    build = [
      {
        os_version = "focal"
        packages = distinct(
          concat(
            DEBIAN_FAMILY_PACKAGES,
            []
          )
        )
      },
      {
        os_version = "jammy"
        packages = distinct(
          concat(
            DEBIAN_FAMILY_PACKAGES,
            []
          )
        )
      },
      {
        os_version = "lunar"
        packages = distinct(
          concat(
            DEBIAN_FAMILY_PACKAGES,
            []
          )
        )
      },
      {
        os_version = "mantic"
        packages = distinct(
          concat(
            DEBIAN_FAMILY_PACKAGES,
            []
          )
        )
      },
      {
        os_version = "noble"
        packages = distinct(
          concat(
            DEBIAN_FAMILY_PACKAGES,
            []
          )
        )
      },
    ]
  }
}
