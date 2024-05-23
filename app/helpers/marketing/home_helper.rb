module Marketing::HomeHelper
  def home_features
    [
      {
        image: 'home/organize.svg',
        title: 'Saving You From Clutter',
        body: 'Whether you’re an individual or a business, we receive and store all your mail, then convert it to high-res PDFs for you. '
      },
      {
        image: 'home/send.svg',
        title: 'Onboard Easily',
        body: 'Our bilingual team helps you get up and running quickly, and ensures your mail is diverted smoothly and efficiently to your new virtual address.'
      },
      {
        image: 'home/message.svg',
        title: 'The Right Information With The Right People',
        body: 'Easily allow your team members, lawyers or accountants to view important mails.'
      },
      {
        image: 'home/search.svg',
        title: 'Advanced Search & Back-Up',
        body: 'Easily scan through your securely stored archive, using text search.'
      },
      {
        image: 'home/browser.svg',
        title: 'Everything Safe In The Cloud',
        body: 'All your physical mail secured under lock and key. '
      },
      {
        image: 'home/pay.svg',
        title: 'We’ll Even Pay Your Bills',
        body: 'If you’ve got invoices or bills to pay, we can interface with non-English speaking organizations, and get them paid them on your behalf.'
      },
    ]
  end

  def home_why_choose_us
    [
      {
        title: 'We Do All The Work For You',
        body: 'You don’t have the time to jump through hoops.<br><br> That’s why we do everything for you. From scanning, translating and storing securely to shredding, and even paying your invoices.'
      },
      {
        title: 'No Contracts / No Hidden Costs',
        body: 'No more hidden charges. <br><br> And, if you decide to leave, no problem! We don’t tie you into a contract.'
      },
      {
        title: 'Absolute Flexibility',
        body: 'Whether you’re in the office, travelling the globe or sat drinking cocktails on the beach, you’ll always have 100% access to all your mail and documents.'
      },
      {
        title: 'Superior Customer Support',
        body: 'If you ever have any questions, our digital mailroom customer service team are the best in the business. And, most importantly, they all speak fluent English.'
      },
      {
        title: 'Security Focused',
        body: 'Security is our #1 priority. All your mail stays under 24/7 surveillance or can be shredded to ensure your privacy.<br><br> Once your mail is digitally converted, it’s encrypted with 256-bit encryption level technology.'
      }
    ]
  end
end
