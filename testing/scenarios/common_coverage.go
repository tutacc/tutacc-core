// +build coverage

package scenarios

import (
	"bytes"
	"os"
	"os/exec"

	"github.com/tutacc/tutacc-core/common/uuid"
)

func BuildTutacc() error {
	genTestBinaryPath()
	if _, err := os.Stat(testBinaryPath); err == nil {
		return nil
	}

	cmd := exec.Command("go", "test", "-tags", "coverage coveragemain", "-coverpkg", "github.com/tutacc/tutacc-core/...", "-c", "-o", testBinaryPath, GetSourcePath())
	return cmd.Run()
}

func RunTutaccProtobuf(config []byte) *exec.Cmd {
	genTestBinaryPath()

	covDir := os.Getenv("TUTACC_COV")
	os.MkdirAll(covDir, os.ModeDir)
	randomID := uuid.New()
	profile := randomID.String() + ".out"
	proc := exec.Command(testBinaryPath, "-config=stdin:", "-format=pb", "-test.run", "TestRunMainForCoverage", "-test.coverprofile", profile, "-test.outputdir", covDir)
	proc.Stdin = bytes.NewBuffer(config)
	proc.Stderr = os.Stderr
	proc.Stdout = os.Stdout

	return proc
}
