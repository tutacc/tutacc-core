package core

//go:generate go get -u github.com/golang/mock/gomock
//go:generate go install github.com/golang/mock/mockgen

//go:generate mockgen -package mocks -destination testing/mocks/io.go -mock_names Reader=Reader,Writer=Writer io Reader,Writer
//go:generate mockgen -package mocks -destination testing/mocks/log.go -mock_names Handler=LogHandler github.com/tutacc/tutacc-core/common/log Handler
//go:generate mockgen -package mocks -destination testing/mocks/mux.go -mock_names ClientWorkerFactory=MuxClientWorkerFactory github.com/tutacc/tutacc-core/common/mux ClientWorkerFactory
//go:generate mockgen -package mocks -destination testing/mocks/dns.go -mock_names Client=DNSClient github.com/tutacc/tutacc-core/features/dns Client
//go:generate mockgen -package mocks -destination testing/mocks/outbound.go -mock_names Manager=OutboundManager,HandlerSelector=OutboundHandlerSelector github.com/tutacc/tutacc-core/features/outbound Manager,HandlerSelector
//go:generate mockgen -package mocks -destination testing/mocks/proxy.go -mock_names Inbound=ProxyInbound,Outbound=ProxyOutbound github.com/tutacc/tutacc-core/proxy Inbound,Outbound
