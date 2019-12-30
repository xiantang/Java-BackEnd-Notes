```shell
JAVA_OPTIONS="-server -XX:+UseG1GC -Xmx512M -XX:MaxDirectMemorySize=128M"
```

=>

```shell
JAVA_OPTIONS="-server -XX:+UseG1GC -Xmx512M -XX:MaxDirectMemorySize=128M -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

