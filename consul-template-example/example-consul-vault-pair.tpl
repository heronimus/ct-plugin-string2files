{{/* "Loop on Consul KV path" */}}
{{ range tree "config/myservices" }} {{ $keytemp := .Key }}
{{- .Value | plugin "/usr/local/bin/string2files" "create" "-f" "-nl" (print "/opt/myservices/" .Key) -}}

{{/* "Get Secret from Vault" */}}
{{ with secret (print "secret/myservice/" $keytemp) }}{{ range $k, $v := .Data }}
{{ if $k }}
{{- (print $k " = " $v) | plugin "/usr/local/bin/string2files" "append" "-f" "-nl" (print "/opt/myservices/" $keytemp) -}}
{{ end }}{{ end -}}{{ end -}}

{{ end -}}
