# frozen_string_literal: true

gcloud_project = attribute('gcloud_project', description="The name of the project where resources are deployed. This should be passed to tk via environment vars.")

control "instance" do
  describe google_compute_instance(project: "#{gcloud_project}",  zone: 'us-west1-a', name: 'database') do
    its('tag_count'){should eq 2}
    its('status') { should eq "RUNNING" }
    its('machine_type') { should match "n1-standard-2" }
    its('first_network_interface_name'){ should eq "external-nat" }
    its('disk_count'){should eq 2}
  end
end
