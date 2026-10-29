{{- define "obs.name" -}}
{{- required "observability.service is required" .Values.observability.service -}}
{{- end -}}
{{- define "obs.team" -}}
{{- required "observability.team is required" .Values.observability.team -}}
{{- end -}}
{{- define "obs.severity" -}}
{{- if eq (int .Values.observability.tier) 1 }}page{{ else }}ticket{{ end -}}
{{- end -}}
{{- define "obs.labels" -}}
team: {{ include "obs.team" . }}
service: {{ include "obs.name" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
