def gen_mappings(os, arch):
  return {
    "tutacc_core/release/doc": "doc",
    "tutacc_core/release/config": "",
    "tutacc_core/main/" + os + "/" + arch: "",
    "tutacc_core/infra/control/main/" + os + "/" + arch: "",
  }
