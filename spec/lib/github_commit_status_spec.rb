require 'spec_helper'

describe GithubCommitStatus do
  subject { GithubCommitStatus.new(build) }
  let(:build) { FactoryGirl.create(:build)}

  it "marks a build as pending" do
    build.update_attributes!(:state => :running)
    stub_request(:post, "https://git.squareup.com/api/v3/repos/square/web/statuses/#{build.ref}").with do |request|
      request.headers["Authorization"].should == "token #{GithubCommitStatus::OAUTH_TOKEN}"
      body = JSON.parse(request.body)
      body["state"].should == "pending"
      body["description"].should_not be_blank
      body["target_url"].should_not be_blank
      true
    end.to_return(:body => commit_status_response)
    subject.update_commit_status!
  end

  it "marks a build as success" do
    build.update_attributes!(:state => :succeeded)
    stub_request(:post, "https://git.squareup.com/api/v3/repos/square/web/statuses/#{build.ref}").with do |request|
      body = JSON.parse(request.body)
      body["state"].should == "success"
      true
    end.to_return(:body => commit_status_response)
    subject.update_commit_status!
  end

  it "marks a build as failure" do
    build.update_attributes!(:state => :failed)
    stub_request(:post, "https://git.squareup.com/api/v3/repos/square/web/statuses/#{build.ref}").with do |request|
      body = JSON.parse(request.body)
      body["state"].should == "failure"
      true
    end.to_return(:body => commit_status_response)
    subject.update_commit_status!
  end

  def commit_status_response
    '{"description":"Build is running","creator":{"gravatar_id":"56fdde43fb3bd6cf62bbec24dc8cb682","login":"nolan","url":"https://git.squareup.com/api/v3/users/nolan","avatar_url":"https://secure.gravatar.com/avatar/56fdde43fb3bd6cf62bbec24dc8cb682?d=https://git.squareup.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png","id":41},"updated_at":"2012-10-06T02:59:18Z","created_at":"2012-10-06T02:59:18Z","state":"success","url":"https://git.squareup.com/api/v3/repos/square/web/statuses/22","target_url":"http://macbuild-master.sfo.squareup.com/projects/web/builds/5510","id":22}'
  end
end