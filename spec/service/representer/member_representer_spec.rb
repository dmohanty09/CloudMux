require 'service_spec_helper'
require 'spec/service/representer/member_representer_context'

describe MemberRepresenter do

  include_context "with a member"

  describe "#to_json" do
    it "should export to json" do
      member.extend(MemberRepresenter)
      result = member.to_json
      result.should eq("{\"member\":{\"id\":\"#{member.id}\",\"account\":{\"id\":\"#{account_1.id}\",\"login\":\"#{account_1.login}\"},\"role\":\"#{member.role}\",\"permissions\":[]}}")
    end
  end

  describe "#from_json" do
    it "should import from json payload" do
      json = "{\"member\":{\"id\":\"#{member.id}\",\"account\":{\"id\":\"#{account_1.id}\",\"login\":\"#{account_1.login}\"},\"role\":\"#{member.role}\"}}"
      new_member = Member.new
      new_member.extend(MemberRepresenter)
      new_member.from_json(json)
      new_member.role.should eq(member.role)
      new_member.id.should eq(member.id)
      new_member.account.login.should eq(member.account.login)
    end
  end
end
