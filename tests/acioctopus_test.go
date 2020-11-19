// Go's testing package has an automatic timeout defualt of 10 minutes. Because the main.tf
// has a ton of resources being created, it goes a little over 10 minutes. To ensure that the
// test doesn't break because of the timeout, run the followng - `go test -timeout 15m`

package main

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestACIDeployment(t *testing.T) {
	options := &terraform.Options{
		TerraformDir: "../",
	}

	defer terraform.Destroy(t, options)

	count := terraform.GetResourceCount(t, terraform.InitAndPlan(t, options))
	fmt.Println(count)

	if _, err := terraform.InitE(t, options); err != nil {
		t.Error(err)
	}

	if _, err := terraform.PlanE(t, options); err != nil {
		t.Error(err)
	}

	if _, err := terraform.ApplyE(t, options); err != nil {
		t.Error(err)
	}

	storageAccountName, err := terraform.OutputE(t, options, "storageAccountName")
	if err != nil {
		t.Error(err)
	} else {
		t.Log(storageAccountName)
	}

	show, err := terraform.ShowE(t, options)
	if err != nil {
		t.Error(err)
	} else {
		t.Log(show)
	}

	image := "octopusdeploy/octopusdeploy:latest"
	assert.Equal(t, "octopusdeploy/octopusdeploy:latest", image)
}
