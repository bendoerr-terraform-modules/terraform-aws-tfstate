package test_test

import (
	"context"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
)

func TestLegacyDdb(t *testing.T) {
	rootFolder := "../"
	terraformFolderRelativeToRoot := "examples/legacy-ddb"

	tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

	rndns := strings.ToLower(random.UniqueId())

	terraformOptions := &terraform.Options{
		TerraformDir: tempTestFolder,
		Upgrade:      true,
		Vars: map[string]interface{}{
			"namespace": rndns,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	cfg, err := config.LoadDefaultConfig(
		context.TODO(),
		config.WithRegion("us-east-1"),
	)
	if err != nil {
		t.Fatal(err)
	}

	lockTableName := terraform.Output(t, terraformOptions, "lock_table_name")
	if lockTableName == "" {
		t.Fatal("lock_table_name output is empty — flag should populate it")
	}

	ddb := dynamodb.NewFromConfig(cfg)
	desc, err := ddb.DescribeTable(context.TODO(), &dynamodb.DescribeTableInput{
		TableName: &lockTableName,
	})
	if err != nil {
		t.Fatalf("DescribeTable(%s) failed: %v", lockTableName, err)
	}
	if desc.Table == nil || desc.Table.TableName == nil || *desc.Table.TableName != lockTableName {
		t.Fatalf("DescribeTable returned unexpected result for %s", lockTableName)
	}
}
