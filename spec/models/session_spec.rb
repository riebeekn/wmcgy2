require 'spec_helper'

describe Session do
  before { @session = Session.new }
  
  subject { @session }
  
  it { should respond_to :email }
  it { should respond_to :password }
  it { should respond_to :remember_me }
end