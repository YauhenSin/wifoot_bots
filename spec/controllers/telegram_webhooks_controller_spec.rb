require 'telegram/bot/updates_controller/rspec_helpers'

RSpec.describe TelegramWebhooksController, type: :telegram_controller do
  include_context 'telegram/bot/updates_controller'
  let(:message_options) { {from: {id: 123}, chat: {id: 456}} }

  prepend(Module.new do
    def dispatch_message(text, options = message_options)
      super(text, options)
    end
  end)

  def reply
    bot.requests[:sendMessage].last
  end

  # TODO: no time to write matcher now.
  def should_reply_with(expected)
    should change { bot.requests[:sendMessage].size }.by(1)
    expect(reply[:chat_id]).to eq message_options[:chat][:id]
    expect(reply[:text]).to eq expected
  end

  describe '#start' do
    subject { -> { dispatch_message "/start" } }
    it { should_reply_with 'Hi there!' }
  end

  describe '#memo' do
    subject { -> { dispatch_message msg } }
    let(:msg) { "/memo #{text}" }
    let(:text) { 'asd qwe' }
    it { should change { session[:memo] }.from(nil).to(text) }
    it { should_reply_with 'Remembered!' }

    context 'when no text given' do
      let(:text) {}
      it { should_not change { session[:memo] }.from(nil) }
      it { should_reply_with 'What should I remember?' }
    end

    context 'when text is given in the second message' do
      before { dispatch_message '/memo' }
      let(:msg) { text }
      it { should change { session[:memo] }.from(nil).to(text) }
      it { should_reply_with 'Remembered!' }
    end
  end

  describe '#remind_me' do
    subject { -> { dispatch_message '/remind_me' } }
    it { should_reply_with 'Nothing to remind' }

    context 'when there is smth stored' do
      let(:stored) { 'stored message' }
      before { session[:memo] = stored }
      it { should_reply_with stored }
    end
  end

  describe '#keyboard' do
    subject { -> { dispatch_message '/keyboard' } }
    it 'shows keyboard' do
      should_reply_with 'Select something with keyboard:'
      expect(reply[:reply_markup]).to be_present
    end

    context 'when keyboard button selected' do
      subject { -> { dispatch_message 'Smth' } }
      before { dispatch_message '/keyboard' }
      it { should_reply_with "You've selected: Smth" }
    end
  end

  describe '#message' do
    subject { -> { dispatch_message text } }
    let(:text ) { 'some plain text' }
    it { should_reply_with "You wrote: #{text}" }
  end

  describe 'for unsupported command' do
    subject { -> { dispatch_message '/makeMeGreatBot' } }
    it { should_reply_with 'Can not perform makemegreatbot' }
  end
end
