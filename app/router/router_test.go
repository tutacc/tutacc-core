package router_test

import (
	"context"
	"testing"

	"github.com/golang/mock/gomock"
	. "github.com/tutacc/tutacc-core/app/router"
	"github.com/tutacc/tutacc-core/common"
	"github.com/tutacc/tutacc-core/common/net"
	"github.com/tutacc/tutacc-core/common/session"
	"github.com/tutacc/tutacc-core/features/outbound"
	"github.com/tutacc/tutacc-core/testing/mocks"
)

type mockOutboundManager struct {
	outbound.Manager
	outbound.HandlerSelector
}

func TestSimpleRouter(t *testing.T) {
	config := &Config{
		Rule: []*RoutingRule{
			{
				TargetTag: &RoutingRule_Tag{
					Tag: "test",
				},
				Networks: []net.Network{net.Network_TCP},
			},
		},
	}

	mockCtl := gomock.NewController(t)
	defer mockCtl.Finish()

	mockDns := mocks.NewDNSClient(mockCtl)
	mockOhm := mocks.NewOutboundManager(mockCtl)
	mockHs := mocks.NewOutboundHandlerSelector(mockCtl)

	r := new(Router)
	common.Must(r.Init(config, mockDns, &mockOutboundManager{
		Manager:         mockOhm,
		HandlerSelector: mockHs,
	}))

	ctx := session.ContextWithOutbound(context.Background(), &session.Outbound{Target: net.TCPDestination(net.DomainAddress("v2fly.org"), 80)})
	tag, err := r.PickRoute(ctx)
	common.Must(err)
	if tag != "test" {
		t.Error("expect tag 'test', bug actually ", tag)
	}
}

func TestSimpleBalancer(t *testing.T) {
	config := &Config{
		Rule: []*RoutingRule{
			{
				TargetTag: &RoutingRule_BalancingTag{
					BalancingTag: "balance",
				},
				Networks: []net.Network{net.Network_TCP},
			},
		},
		BalancingRule: []*BalancingRule{
			{
				Tag:              "balance",
				OutboundSelector: []string{"test-"},
			},
		},
	}

	mockCtl := gomock.NewController(t)
	defer mockCtl.Finish()

	mockDns := mocks.NewDNSClient(mockCtl)
	mockOhm := mocks.NewOutboundManager(mockCtl)
	mockHs := mocks.NewOutboundHandlerSelector(mockCtl)

	mockHs.EXPECT().Select(gomock.Eq([]string{"test-"})).Return([]string{"test"})

	r := new(Router)
	common.Must(r.Init(config, mockDns, &mockOutboundManager{
		Manager:         mockOhm,
		HandlerSelector: mockHs,
	}))

	ctx := session.ContextWithOutbound(context.Background(), &session.Outbound{Target: net.TCPDestination(net.DomainAddress("v2fly.org"), 80)})
	tag, err := r.PickRoute(ctx)
	common.Must(err)
	if tag != "test" {
		t.Error("expect tag 'test', bug actually ", tag)
	}
}

func TestIPOnDemand(t *testing.T) {
	config := &Config{
		DomainStrategy: Config_IpOnDemand,
		Rule: []*RoutingRule{
			{
				TargetTag: &RoutingRule_Tag{
					Tag: "test",
				},
				Cidr: []*CIDR{
					{
						Ip:     []byte{192, 168, 0, 0},
						Prefix: 16,
					},
				},
			},
		},
	}

	mockCtl := gomock.NewController(t)
	defer mockCtl.Finish()

	mockDns := mocks.NewDNSClient(mockCtl)
	mockDns.EXPECT().LookupIP(gomock.Eq("v2fly.org")).Return([]net.IP{{192, 168, 0, 1}}, nil).AnyTimes()

	r := new(Router)
	common.Must(r.Init(config, mockDns, nil))

	ctx := session.ContextWithOutbound(context.Background(), &session.Outbound{Target: net.TCPDestination(net.DomainAddress("v2fly.org"), 80)})
	tag, err := r.PickRoute(ctx)
	common.Must(err)
	if tag != "test" {
		t.Error("expect tag 'test', bug actually ", tag)
	}
}

func TestIPIfNonMatchDomain(t *testing.T) {
	config := &Config{
		DomainStrategy: Config_IpIfNonMatch,
		Rule: []*RoutingRule{
			{
				TargetTag: &RoutingRule_Tag{
					Tag: "test",
				},
				Cidr: []*CIDR{
					{
						Ip:     []byte{192, 168, 0, 0},
						Prefix: 16,
					},
				},
			},
		},
	}

	mockCtl := gomock.NewController(t)
	defer mockCtl.Finish()

	mockDns := mocks.NewDNSClient(mockCtl)
	mockDns.EXPECT().LookupIP(gomock.Eq("v2fly.org")).Return([]net.IP{{192, 168, 0, 1}}, nil).AnyTimes()

	r := new(Router)
	common.Must(r.Init(config, mockDns, nil))

	ctx := session.ContextWithOutbound(context.Background(), &session.Outbound{Target: net.TCPDestination(net.DomainAddress("v2fly.org"), 80)})
	tag, err := r.PickRoute(ctx)
	common.Must(err)
	if tag != "test" {
		t.Error("expect tag 'test', bug actually ", tag)
	}
}

func TestIPIfNonMatchIP(t *testing.T) {
	config := &Config{
		DomainStrategy: Config_IpIfNonMatch,
		Rule: []*RoutingRule{
			{
				TargetTag: &RoutingRule_Tag{
					Tag: "test",
				},
				Cidr: []*CIDR{
					{
						Ip:     []byte{127, 0, 0, 0},
						Prefix: 8,
					},
				},
			},
		},
	}

	mockCtl := gomock.NewController(t)
	defer mockCtl.Finish()

	mockDns := mocks.NewDNSClient(mockCtl)

	r := new(Router)
	common.Must(r.Init(config, mockDns, nil))

	ctx := session.ContextWithOutbound(context.Background(), &session.Outbound{Target: net.TCPDestination(net.LocalHostIP, 80)})
	tag, err := r.PickRoute(ctx)
	common.Must(err)
	if tag != "test" {
		t.Error("expect tag 'test', bug actually ", tag)
	}
}
