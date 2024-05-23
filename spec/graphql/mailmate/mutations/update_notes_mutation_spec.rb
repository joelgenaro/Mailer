require 'rails_helper'

RSpec.describe Mailmate::Mutations::UpdateNotesMutation, type: :request do
  include MailmateGraphQLHelper

  before(:all) do 
    @user = create(:user)
    @mail_inbox = create(:mail_inbox, user: @user)
    @postal_mail = create(:mail_postal_mail, inbox: @mail_inbox)
  end

  it 'authenticates user' do
    ensure_user_authenticated(query(@postal_mail.id, "Hello world")) 
  end

  it "updates a postal mail's notes" do 
    expect(@postal_mail.notes).to_not eq("Hello world")
    authorized_request(@user, query(@postal_mail.id, "Hello world")) 
    data = response.parsed_body['data']['updateNotes']
    expect(data).to eq({
      "id"=>@postal_mail.id.to_s,
      "notes"=>"Hello world",
      "user"=>{
        "id"=>@user.id.to_s
      }
    })
    @postal_mail.reload
    expect(@postal_mail.notes).to eq("Hello world")
  end

  def query(postal_mail_id, notes)
    <<~GQL
      mutation {
        updateNotes(input: { id: "#{postal_mail_id}", notes: "#{notes}" } ) {
          id
          notes
          user {
            id
          }
        }
      }
    GQL
  end
end