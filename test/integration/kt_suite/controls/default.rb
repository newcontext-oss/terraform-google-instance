control "instance" do
  describe command('gcloud compute instances describe database') do
    its('stdout') { should match (/name: database/) }
    its('stdout') { should match (/- key: sshKeys/) }
    its('stdout') { should match (/status: RUNNING/) }
  end
end