# alx-home vcpkg Registry

Custom vcpkg registry for alx-home C++ ports.

## Available Ports

- `alx-build-tools`
- `alx-cpp-utils`
- `alx-promise`

## Usage

Add this registry to your `vcpkg-configuration.json`:

```json
{
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/alx-home/vcpkg-registry.git",
      "baseline": "<commit-sha>",
      "packages": [
        "alx-build-tools",
        "alx-cpp-utils",
        "alx-promise"
      ]
    }
  ]
}
```

Or install directly from local overlay ports while developing:

```powershell
vcpkg install alx-cpp-utils --overlay-ports=./ports
vcpkg install alx-promise --overlay-ports=./ports
```

## Notes

- Ports are versioned in `versions/`.
- Source retrieval is pinned by ref and SHA512 in each `portfile.cmake`.
