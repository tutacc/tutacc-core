package ctlcmd

import (
	"io"
	"os"
	"os/exec"
	"strings"

	"github.com/tutacc/tutacc-core/common/buf"
	"github.com/tutacc/tutacc-core/common/platform"
)

//go:generate errorgen

func Run(args []string, input io.Reader) (buf.MultiBuffer, error) {
	tutactl := platform.GetToolLocation("tutactl")
	if _, err := os.Stat(tutactl); err != nil {
		return nil, newError("tutactl doesn't exist").Base(err)
	}

	var errBuffer buf.MultiBufferContainer
	var outBuffer buf.MultiBufferContainer

	cmd := exec.Command(tutactl, args...)
	cmd.Stderr = &errBuffer
	cmd.Stdout = &outBuffer
	cmd.SysProcAttr = getSysProcAttr()
	if input != nil {
		cmd.Stdin = input
	}

	if err := cmd.Start(); err != nil {
		return nil, newError("failed to start tutactl").Base(err)
	}

	if err := cmd.Wait(); err != nil {
		msg := "failed to execute tutactl"
		if errBuffer.Len() > 0 {
			msg += ": \n" + strings.TrimSpace(errBuffer.MultiBuffer.String())
		}
		return nil, newError(msg).Base(err)
	}

	// log stderr, info message
	if !errBuffer.IsEmpty() {
		newError("<tutactl message> \n", strings.TrimSpace(errBuffer.MultiBuffer.String())).AtInfo().WriteToLog()
	}

	return outBuffer.MultiBuffer, nil
}
