{{/* "Loop on Consul KV path, then write K/V to files" */}}
{{ range tree "config/myservices" }}
{{- .Value | plugin "/usr/local/bin/string2files" "create" "-f" "-nl" (print "/opt/myservices/" .Key) -}}
{{ end -}}
