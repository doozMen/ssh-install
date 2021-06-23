# ssh-install
[![Swift](https://github.com/doozMen/ssh-install/actions/workflows/swift.yml/badge.svg)](https://github.com/doozMen/ssh-install/actions/workflows/swift.yml)

```swift
    .package(url: "https://github.com/doozMen/ssh-install.git", .upToNextMajor(from: "0.0.1"))
```
## useage

1. clone repo
2. `swift run ssh-install -h`

## use in github actions


You can add the code below if you  added a folder with a copy or simular content of 

The secrets should have been added to repo settings secrets. [more info](https://docs.github.com/en/actions/reference/encrypted-secrets)

* PRIVATE_KEY
* PUBLIC_KEY
* SSH_CONFIG 


```yml
steps:
    - name: cache SPM buildtools
        uses: actions/cache@v2.1.6
        with:
            path: BuildTools/.build
            key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
            restore-keys: |
            ${{ runner.os }}-spm-
    - name: "build BuildTools"
          run: swift build -c release --package-path BuildTools
    - name: "Set up SSH agent"
          run: |
            echo "${{secrets.PRIVATE_KEY }}" >> ~/privateKey
            echo "${{secrets.PUBLIC_KEY }}" >> ~/publicKey
            echo "${{secrets.SSH_CONFIG }}" >> ~/config
            swift run  --skip-build -c release --package-path BuildTools ssh-install ~/privateKey ~/publicKey ~/config
```
