package test_test

import (
	"context"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestSimple(t *testing.T) {
	ctx := context.Background()

	rootFolder := "../"
	terraformFolderRelativeToRoot := "examples/simple"

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	rndns := strings.ToLower(random.UniqueID())

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"namespace": rndns,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.DestroyContext(ctx, t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApplyContext(ctx, t, terraformOptions)

	// AWS Session
	_, err := config.LoadDefaultConfig(
		ctx,
		config.WithRegion("us-east-1"),
	)

	if err != nil {
		t.Fatal(err)
	}
}
