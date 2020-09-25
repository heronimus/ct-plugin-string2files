# Consul-Template Plugin: string2files
Consul-Template plugin that (basically) write string to file(s). Created because I need easy way to write multiple files from Consul KV tree :v:.

### Credits
This plugin heavily inspired by:
- [tam7t/certdump.go Gist](https://gist.github.com/tam7t/1b45125ae4de13b3fc6fd0455954c08e)
- [ekristen/consul-template-plugin-savetofile](https://github.com/ekristen/consul-template-plugin-savetofile)

Both of above code already working nice, but I do some modification and mainly as an experiment to try new language ([V-lang](https://github.com/vlang/v)) and make it more lightweight binary (320~ kB) (it's seriously promising new prog. language and fun to try, they have an active community too on Discord).

### What It Can Do
- Write/append string to file.
- Split string and write them to multiple files.
- Allow you to write **multiple files from Consul KV Tree** with only single Consul-Template file.
- Combine Consul KV + Vault Secret and write it to files, and basicly write to file any string you can get from Consul Templates.
- ...

### Installation

- Download the executable binary from [releases page](https://github.com/heronimus/ct-plugin-string2files/releases).
- Give execute permission & copy to your path
  ```
  chmod +x string2files
  mv string2files-v0.1.0 /usr/local/bin/string2files
  ```

### Usages

Usage: `strings2files [commands] [flags] <arguments..>`

```
Flags:
  -help               Prints help information.
  -f   --force        Create new directory/file from <path-file> if not exist.
  -nl  --new-line     Add new line in the end of file.

Commands:
  append              MODE: Append string to file.
  create              MODE: Write string to file.
  explode             MODE: Split text and write to multiple file.
  help                Prints help information.
  version             Prints version information.

Arguments:
  append              <file-path> <content>
  create              <file-path> <content>
  explode             <base-path> <separator> <content>
```

### Examples (execute binary directly):

- Create file `/opt/files/key-example.txt` with file-content `value-example`:
    ```
    strings2files create /opt/files/key-example.txt "value-example"
    ```
    force directory creation if not exist (`-f`), and add new-line (`-nl`) on the end of the file.
    ```
    strings2files create -f -nl /opt/files/key-example.txt "value-example"
    ```

<br>

- Append file-content `value-example` to`/opt/files/key-example.txt`:
    ```
    strings2files append /opt/files/key-example.txt "value-example-appended"
    ```

<br>

- Explode combined key-value strings separated by delimiter:
    ```
    strings2files explode /opt/files/ ";" "key1.txt;value1;key2.txt;value2;child/key3;value3"
    ```
    will create following files tree:
    ```
    /opt/files/
    │   key1.txt        value1
    │   key2.txt        value2
    │
    └─── child/
        │  key3.txt     value3

    ```

<br>

### Examples (as Consul Template Plugin):
These are just a few examples that bring me to create this plugin. Basically, this plugin only writes value given into a file, so it may have many possibilities how you can make use of this plugin.

<br>

For Example: given below items on Consul KV & Vault Secret:
- Consul KV:
  ```
  config/myservices
      │   app.conf         app.name="myservices"
      │
      └─── db/
          │  db.conf       db.host="127.0.0.1:5432"
  ```
- Vault Secret:
  ```
  secret/myservices
      │   app.conf        
      |      - app.token    "s3cr3t-t0k3n"
      │
      └─── db/db.conf
          │  - db.username  "mydb"
          │  - db.password  "pass1234"
  ```

<br>

Use cases example:
- **Example 1** (Consul KV Tree): `example/example-consul-kv-tree.tpl`
  ```
  {{ range tree "config/myservices" }}
  {{- .Value | plugin "/usr/local/bin/string2files" "create" "-f" "-nl" (print "/opt/myservices/" .Key) -}}
  {{ end -}}
  ```
  execute command:
  ```
  consul-template -template "example-consul-kv-tree.tpl:debug.log" -once
  ```
  result:
  ```
  /opt/myservices/
      │   app.conf         app.name="myservices"
      │
      └─── db/
          │  db.conf       db.host="127.0.0.1:5432"
  ```

- **Example 2** (Consul KV Tree + Vault Secret appended): `example/example-consul-vault-pair.tpl`
  >*Please notes that Consul KV and Vault Secret of this example have same directory structure.
  ```
  {{ range tree "config/myservices" }} {{ $keytemp := .Key }}
  {{- .Value | plugin "/usr/local/bin/string2files" "create" "-f" "-nl" (print "/opt/myservices/" .Key) -}}

  {{ with secret (print "secret/myservice/" $keytemp) }}{{ range $k, $v := .Data }}
  {{ if $k }}
  {{- (print $k "=" $v) | plugin "/usr/local/bin/string2files" "append" "-f" "-nl" (print "/opt/myservices/" $keytemp) -}}
  {{ end }}{{ end -}}{{ end -}}

  {{ end -}}
  ```
  execute command:
  ```
  consul-template -vault-addr <vault-host> -vault-token=<vault-token> -vault-renew-token=false  -template "example-consul-vault-pair.tpl:debug.log" -once
  ```
  result:
  ```
  /opt/myservices/
      │   app.conf         app.name="myservices"
      |                    app.token = s3cr3t-t0k3n
      │
      └─── db/
          │  db.conf       db.host="127.0.0.1:5432"
          |                db.password = pass1234
          |                db.username = mydb
  ```

- **Example 3** (Consul KV Tree with explode mode): `example/example-splits-from-string.tpl`
  > *The explode mode allows you to freely construct the data first, then pass the whole strings to the plugin, as the plugin will split the key/value by the separator and create file(s) based on that.
  ```
  {{/* "Initiate Variable" */}}
  {{ $separator := "=====" -}}
  {{ $data := "" -}}

  {{/* "Constructing string to .Data variable" */}}
  {{ range tree "config/myservices" }}
  {{- $data = (print $data .Key $separator .Value $separator) -}}
  {{ end -}}

  {{/* "Executing plugin exclude ..." */}}
  {{ with $data }}
  {{ . | plugin "/usr/local/bin/string2files" "explode" "-f" "-nl" "/opt/myservices/" $separator }}{{ end }}
  ```
  execute command:
  ```
  consul-template -template "example-splits-from-string.tpl:debug.log" -once
  ```
  result:
  ```
  /opt/myservices/
      │   app.conf         app.name="myservices"
      │
      └─── db/
          │  db.conf       db.host="127.0.0.1:5432"
  ```

### References
More references about Consul Template and Consul Template plugin, please see official documentation:
- https://github.com/hashicorp/consul-template/#usage
- https://github.com/hashicorp/consul-template/#plugins

### Build from source
This plugin written in V, so you must have V compiler installed.

- Install V (Linux, macOS, Windows, *BSD, Solaris, WSL, Android, Raspbian)
  ```
  git clone https://github.com/vlang/v
  cd v
  make
  ```
- Symlink V
  - On Unix system
    ```
    sudo ./v symlink
    ```
  - On Windows
    ```
    .\v.exe symlink
    ```

- Clone this repository
  ```
  git clone https://github.com/heronimus/ct-plugin-string2files.git
  ```

- Build the code
  ```
  cd ct-plugin-string2files
  v string2files.v
  ```

- Binary will created at working directory (`string2files` / `string2files.exe` for Windows)
> *Notes: V allows you to cross compilation by passing flag `-os <windows/linux>`, macOS binary only can be compiled on macOS platform.

### More About V
Please visit official website and docs:
- https://vlang.io/
- https://github.com/vlang/v/blob/master/doc/docs.md
