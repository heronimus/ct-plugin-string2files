{{/* "Initiate Variable" */}}
{{ $separator := "=====" -}}
{{ $data := "" -}}

{{/* "Constructing string on $data variable" */}}
{{ range tree "config/myservices" }}
{{- $data = (print $data .Key $separator .Value $separator) -}}
{{ end -}}

{{/* "Executing plugin exclude ..." */}}
{{ with $data }}
{{ . | plugin "/usr/local/bin/string2files" "explode" "-f" "-nl" "/opt/myservices/" $separator }}{{ end }}
