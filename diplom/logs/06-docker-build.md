### Сборка образа приложения

```
$ docker build --build-arg VERSION=test -t diplom-app:test .
#9 exporting config sha256:5c411eb4a33cac3bbf1cb78ace7acbac7e707e092f5bb246f37ae2f88c6b6fca done
#9 exporting attestation manifest sha256:6a90e46c857464c04644e6333315ee36088d7cce2d925c656a145296efbbc589 0.0s done
#9 exporting manifest list sha256:dbdfa97e453077ac709e566c45cdfbbe41cadc568bd26c266f5bf9a47f3b098c done
#9 naming to docker.io/library/diplom-app:test done
#9 unpacking to docker.io/library/diplom-app:test done
#9 DONE 0.1s

$ docker run --rm -d -p 8099:80 --name diplom-test diplom-app:test
e3d952628377329e19b0c592f1d77ce3b6875064972fcc31cc61785b83f16f24

$ curl -s localhost:8099 | grep version
    <p>Ларин Владимир</p>
    <p class="ver">version: test</p>

$ curl -s localhost:8099/healthz
ok
```
