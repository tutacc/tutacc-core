package all

import (
	// The following are necessary as they register handlers in their init functions.

	// Required features. Can't remove unless there is replacements.
	_ "github.com/tutacc/tutacc-core/app/dispatcher"
	_ "github.com/tutacc/tutacc-core/app/proxyman/inbound"
	_ "github.com/tutacc/tutacc-core/app/proxyman/outbound"

	// Default commander and all its services. This is an optional feature.
	_ "github.com/tutacc/tutacc-core/app/commander"
	_ "github.com/tutacc/tutacc-core/app/log/command"
	_ "github.com/tutacc/tutacc-core/app/proxyman/command"
	_ "github.com/tutacc/tutacc-core/app/stats/command"

	// Other optional features.
	_ "github.com/tutacc/tutacc-core/app/dns"
	_ "github.com/tutacc/tutacc-core/app/log"
	_ "github.com/tutacc/tutacc-core/app/policy"
	_ "github.com/tutacc/tutacc-core/app/reverse"
	_ "github.com/tutacc/tutacc-core/app/router"
	_ "github.com/tutacc/tutacc-core/app/stats"

	// Inbound and outbound proxies.
	_ "github.com/tutacc/tutacc-core/proxy/blackhole"
	_ "github.com/tutacc/tutacc-core/proxy/dns"
	_ "github.com/tutacc/tutacc-core/proxy/dokodemo"
	_ "github.com/tutacc/tutacc-core/proxy/freedom"
	_ "github.com/tutacc/tutacc-core/proxy/http"
	_ "github.com/tutacc/tutacc-core/proxy/mtproto"
	_ "github.com/tutacc/tutacc-core/proxy/shadowsocks"
	_ "github.com/tutacc/tutacc-core/proxy/socks"
	_ "github.com/tutacc/tutacc-core/proxy/vmess/inbound"
	_ "github.com/tutacc/tutacc-core/proxy/vmess/outbound"

	// Transports
	_ "github.com/tutacc/tutacc-core/transport/internet/domainsocket"
	_ "github.com/tutacc/tutacc-core/transport/internet/http"
	_ "github.com/tutacc/tutacc-core/transport/internet/kcp"
	_ "github.com/tutacc/tutacc-core/transport/internet/quic"
	_ "github.com/tutacc/tutacc-core/transport/internet/tcp"
	_ "github.com/tutacc/tutacc-core/transport/internet/tls"
	_ "github.com/tutacc/tutacc-core/transport/internet/udp"
	_ "github.com/tutacc/tutacc-core/transport/internet/websocket"

	// Transport headers
	_ "github.com/tutacc/tutacc-core/transport/internet/headers/http"
	_ "github.com/tutacc/tutacc-core/transport/internet/headers/noop"
	_ "github.com/tutacc/tutacc-core/transport/internet/headers/srtp"
	_ "github.com/tutacc/tutacc-core/transport/internet/headers/tls"
	_ "github.com/tutacc/tutacc-core/transport/internet/headers/utp"
	_ "github.com/tutacc/tutacc-core/transport/internet/headers/wechat"
	_ "github.com/tutacc/tutacc-core/transport/internet/headers/wireguard"

	// JSON config support. Choose only one from the two below.
	// The following line loads JSON from tutactl
	_ "github.com/tutacc/tutacc-core/main/json"
	// The following line loads JSON internally
	// _ "github.com/tutacc/tutacc-core/main/jsonem"

	// Load config from file or http(s)
	_ "github.com/tutacc/tutacc-core/main/confloader/external"
)
