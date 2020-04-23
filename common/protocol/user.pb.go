package protocol

import (
	fmt "fmt"
	proto "github.com/golang/protobuf/proto"
	math "math"
	serial "github.com/tutacc/tutacc-core/common/serial"
)

// Reference imports to suppress errors if they are not otherwise used.
var _ = proto.Marshal
var _ = fmt.Errorf
var _ = math.Inf

// This is a compile-time assertion to ensure that this generated file
// is compatible with the proto package it is being compiled against.
// A compilation error at this line likely means your copy of the
// proto package needs to be updated.
const _ = proto.ProtoPackageIsVersion3 // please upgrade the proto package

// User is a generic user for all procotols.
type User struct {
	Level uint32 `protobuf:"varint,1,opt,name=level,proto3" json:"level,omitempty"`
	Email string `protobuf:"bytes,2,opt,name=email,proto3" json:"email,omitempty"`
	// Protocol specific account information. Must be the account proto in one of the proxies.
	Account              *serial.TypedMessage `protobuf:"bytes,3,opt,name=account,proto3" json:"account,omitempty"`
	XXX_NoUnkeyedLiteral struct{}             `json:"-"`
	XXX_unrecognized     []byte               `json:"-"`
	XXX_sizecache        int32                `json:"-"`
}

func (m *User) Reset()         { *m = User{} }
func (m *User) String() string { return proto.CompactTextString(m) }
func (*User) ProtoMessage()    {}
func (*User) Descriptor() ([]byte, []int) {
	return fileDescriptor_9da52c16030369bd, []int{0}
}

func (m *User) XXX_Unmarshal(b []byte) error {
	return xxx_messageInfo_User.Unmarshal(m, b)
}
func (m *User) XXX_Marshal(b []byte, deterministic bool) ([]byte, error) {
	return xxx_messageInfo_User.Marshal(b, m, deterministic)
}
func (m *User) XXX_Merge(src proto.Message) {
	xxx_messageInfo_User.Merge(m, src)
}
func (m *User) XXX_Size() int {
	return xxx_messageInfo_User.Size(m)
}
func (m *User) XXX_DiscardUnknown() {
	xxx_messageInfo_User.DiscardUnknown(m)
}

var xxx_messageInfo_User proto.InternalMessageInfo

func (m *User) GetLevel() uint32 {
	if m != nil {
		return m.Level
	}
	return 0
}

func (m *User) GetEmail() string {
	if m != nil {
		return m.Email
	}
	return ""
}

func (m *User) GetAccount() *serial.TypedMessage {
	if m != nil {
		return m.Account
	}
	return nil
}

func init() {
	proto.RegisterType((*User)(nil), "tutacc.core.common.protocol.User")
}

func init() {
	proto.RegisterFile("github.com/tutacc/tutacc-core/common/protocol/user.proto", fileDescriptor_9da52c16030369bd)
}

var fileDescriptor_9da52c16030369bd = []byte{
	// 218 bytes of a gzipped FileDescriptorProto
	0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0xe2, 0xd2, 0x2c, 0x33, 0x2a, 0x4a,
	0xac, 0xd4, 0x4b, 0xce, 0xcf, 0xd5, 0x4f, 0xce, 0x2f, 0x4a, 0xd5, 0x4f, 0xce, 0xcf, 0xcd, 0xcd,
	0xcf, 0xd3, 0x2f, 0x28, 0xca, 0x2f, 0xc9, 0x4f, 0xce, 0xcf, 0xd1, 0x2f, 0x2d, 0x4e, 0x2d, 0xd2,
	0x03, 0xf3, 0x84, 0xa4, 0x60, 0x4a, 0x8b, 0x52, 0xf5, 0x20, 0xca, 0xf4, 0x60, 0xca, 0xa4, 0x0c,
	0xb0, 0x1b, 0x53, 0x9c, 0x5a, 0x94, 0x99, 0x98, 0xa3, 0x5f, 0x52, 0x59, 0x90, 0x9a, 0x12, 0x9f,
	0x9b, 0x5a, 0x5c, 0x9c, 0x98, 0x9e, 0x0a, 0xd1, 0xa4, 0x54, 0xc2, 0xc5, 0x12, 0x5a, 0x9c, 0x5a,
	0x24, 0x24, 0xc2, 0xc5, 0x9a, 0x93, 0x5a, 0x96, 0x9a, 0x23, 0xc1, 0xa8, 0xc0, 0xa8, 0xc1, 0x1b,
	0x04, 0xe1, 0x80, 0x44, 0x53, 0x73, 0x13, 0x33, 0x73, 0x24, 0x98, 0x14, 0x18, 0x35, 0x38, 0x83,
	0x20, 0x1c, 0x21, 0x07, 0x2e, 0xf6, 0xc4, 0xe4, 0xe4, 0xfc, 0xd2, 0xbc, 0x12, 0x09, 0x66, 0x05,
	0x46, 0x0d, 0x6e, 0x23, 0x35, 0x3d, 0x4c, 0x37, 0x41, 0xec, 0xd4, 0x0b, 0x01, 0xd9, 0xe9, 0x0b,
	0xb1, 0x32, 0x08, 0xa6, 0xcd, 0xc9, 0x93, 0x4b, 0x2e, 0x39, 0x3f, 0x57, 0x0f, 0xb7, 0x4f, 0x02,
	0x18, 0xa3, 0x38, 0x60, 0xec, 0x55, 0x4c, 0x52, 0x61, 0x46, 0x41, 0x89, 0x95, 0x7a, 0xce, 0x20,
	0x85, 0xce, 0x10, 0x85, 0x01, 0x50, 0xc9, 0x24, 0x36, 0xb0, 0x32, 0x63, 0x40, 0x00, 0x00, 0x00,
	0xff, 0xff, 0x02, 0xf5, 0x15, 0xcc, 0x42, 0x01, 0x00, 0x00,
}
