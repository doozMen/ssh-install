# ssh-install
[![Swift](https://github.com/doozMen/ssh-install/actions/workflows/swift.yml/badge.svg)](https://github.com/doozMen/ssh-install/actions/workflows/swift.yml)

```swift
    .package(url: "https://github.com/doozMen/ssh-install.git", .upToNextMajor(from: "0.0.1"))
```
## useage

1. clone repo
2. `swift run ssh-install -h`

## use in github actions


```yml
- name: "Set up SSH agent"
      run: |
        echo "${{secrets.PRIVATE_KEY }}" >> ~/privateKey
        echo "${{secrets.PUBLIC_KEY }}" >> ~/publicKey
        echo "${{secrets.SSH_CONFIG }}" >> ~/config
        swift run -c release --package-path BuildTools ssh-install ~/privateKey ~/publicKey ~/config
```