package tun

import (
	"net"
	"os"
	"strconv"

	"golang.org/x/sys/unix"
)

// externalTunFD returns a TUN file descriptor provided by a parent process, or 0.
//
// SING_BOX_TUN_FD: an inherited descriptor number.
// SING_BOX_TUN_SOCKET: a unix socket (abstract when it starts with '@') that sends the
// descriptor with SCM_RIGHTS on connect. Android's ProcessBuilder closes inherited
// descriptors, so a VpnService passes its TUN this way.
func externalTunFD() int {
	if fd, err := strconv.Atoi(os.Getenv("SING_BOX_TUN_FD")); err == nil && fd > 0 {
		return fd
	}
	path := os.Getenv("SING_BOX_TUN_SOCKET")
	if path == "" {
		return 0
	}
	conn, err := net.DialUnix("unix", nil, &net.UnixAddr{Name: path, Net: "unix"})
	if err != nil {
		return 0
	}
	defer conn.Close()
	buf := make([]byte, 1)
	oob := make([]byte, unix.CmsgSpace(4))
	_, oobn, _, _, err := conn.ReadMsgUnix(buf, oob)
	if err != nil {
		return 0
	}
	msgs, err := unix.ParseSocketControlMessage(oob[:oobn])
	if err != nil || len(msgs) == 0 {
		return 0
	}
	fds, err := unix.ParseUnixRights(&msgs[0])
	if err != nil || len(fds) == 0 {
		return 0
	}
	return fds[0]
}
