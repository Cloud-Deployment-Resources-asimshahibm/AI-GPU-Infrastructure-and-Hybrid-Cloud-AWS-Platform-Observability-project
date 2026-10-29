// Package obs sets up OpenTelemetry tracing and trace-aware JSON logging in one call.
package obs

import (
	"context"
	"log/slog"
	"os"

	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
	"go.opentelemetry.io/otel/trace"
)

// Config describes the service being instrumented.
type Config struct {
	Service string
	Team    string
	Env     string
}

// Setup configures the global tracer provider and returns a shutdown func and a JSON logger.
func Setup(ctx context.Context, cfg Config) (func(context.Context) error, *slog.Logger, error) {
	if cfg.Env == "" {
		cfg.Env = getenv("DEPLOY_ENV", "prod")
	}
	exp, err := otlptracegrpc.New(ctx,
		otlptracegrpc.WithEndpoint(getenv("OTEL_AGENT_ENDPOINT", "otel-agent-collector.observability:4317")),
		otlptracegrpc.WithInsecure(),
	)
	if err != nil {
		return nil, nil, err
	}
	res, err := resource.Merge(resource.Default(), resource.NewSchemaless(
		attribute.String("service.name", cfg.Service),
		attribute.String("team", cfg.Team),
		attribute.String("deployment.environment", cfg.Env),
		attribute.String("k8s.cluster.name", getenv("CLUSTER_NAME", "unknown")),
	))
	if err != nil {
		return nil, nil, err
	}
	tp := sdktrace.NewTracerProvider(sdktrace.WithBatcher(exp), sdktrace.WithResource(res))
	otel.SetTracerProvider(tp)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(propagation.TraceContext{}, propagation.Baggage{}))

	logger := slog.New(&traceHandler{Handler: slog.NewJSONHandler(os.Stdout, nil)}).With("service", cfg.Service)
	return tp.Shutdown, logger, nil
}

// traceHandler adds trace_id and span_id to every log record that has an active span.
type traceHandler struct{ slog.Handler }

func (h *traceHandler) Handle(ctx context.Context, r slog.Record) error {
	if sc := trace.SpanContextFromContext(ctx); sc.IsValid() {
		r.AddAttrs(slog.String("trace_id", sc.TraceID().String()), slog.String("span_id", sc.SpanID().String()))
	}
	return h.Handler.Handle(ctx, r)
}

func (h *traceHandler) WithAttrs(a []slog.Attr) slog.Handler {
	return &traceHandler{h.Handler.WithAttrs(a)}
}
func (h *traceHandler) WithGroup(n string) slog.Handler { return &traceHandler{h.Handler.WithGroup(n)} }

func getenv(k, d string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return d
}
