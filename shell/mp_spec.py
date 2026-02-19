#!/usr/bin/env python3
import json, sys

def bytes_to_mib(x) -> int:
    # multipass json uses bytes as string, e.g. "5116440064"
    return int(round(int(str(x)) / (1024 * 1024)))

def pick_vm(obj: dict, name: str) -> dict:
    info = obj.get("info", {})
    if name in info:
        return info[name]
    # fallback: first vm
    return next(iter(info.values()), {})

def get_cpu(vm: dict) -> int:
    # your output shows "cpu_count": "1"
    if "cpu_count" in vm:
        return int(vm["cpu_count"])
    # fallback for other shapes
    if "resources" in vm and "cpus" in vm["resources"]:
        return int(vm["resources"]["cpus"])
    raise KeyError("cpu_count not found")

def get_mem_mib(vm: dict) -> int:
    # common on recent multipass: "memory": {"total":"...", "used":"..."}
    mem = vm.get("memory")
    if isinstance(mem, dict) and "total" in mem:
        return bytes_to_mib(mem["total"])
    # fallback older shapes
    if "resources" in vm and "memory" in vm["resources"]:
        # might be "2.0GiB" style; if you ever see that, tell me and I'll add parsing
        raise KeyError("resources.memory is not bytes; need parser")
    raise KeyError("memory.total not found")

def get_disk_mib(vm: dict) -> int:
    # your output shows: "disks": {"sda1": {"total":"...", "used":"..."}}
    disks = vm.get("disks")
    if isinstance(disks, dict):
        totals = []
        for d in disks.values():
            if isinstance(d, dict) and "total" in d:
                totals.append(bytes_to_mib(d["total"]))
        if totals:
            return max(totals)
    raise KeyError("disks.*.total not found")

def main():
    if len(sys.argv) != 2:
        print("usage: mp_spec.py <vmname>", file=sys.stderr)
        return 2

    name = sys.argv[1]
    j = json.load(sys.stdin)
    vm = pick_vm(j, name)
    if not vm:
        raise RuntimeError(f"vm not found: {name}")

    cpu = get_cpu(vm)
    mem_mib = get_mem_mib(vm)
    disk_mib = get_disk_mib(vm)

    print(f"{cpu} {mem_mib} {disk_mib}")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
