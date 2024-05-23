module Marketing::PricingHelper
  def pricing_plan_classes(plan, plan_type = 'assistant')
    classes = ['plan']
    classes << "plan--red" if  (plan_type == 'mail' && plan.dig(:content, :type) == 'individual')
    classes << "plan--green" if  (plan_type == 'assistant' && plan.dig(:content, :type) == 'individual')
    classes << "plan--most-popular" if plan[:most_popular].present? || plan.dig(:content, :most_popular).present?
    classes.join(' ')
  end

  def pricing_comparison_color(plan, plan_type = 'assistant')
    return 'red' if (plan_type == 'mail' && plan.dig(:content, :most_popular).present?)
    return 'green' if (plan_type == 'assistant' && plan.dig(:content, :type) == 'individual')
    return 'blue' if (plan_type == 'assistant' && plan.dig(:content, :type) == 'business')
    return 'grey'
  end

  # MARK: Assistant

  def assistant_features
    [
      {
        icon: 'marketing/pricing/pay-bills.svg',
        label: 'Pay bills on your behalf',
        text: 'Your assistant can take care of your bills for you.',
        disclaimer: 'Processing fee for bills below ¥50,000 is ¥500 + 3% of the amount, for bills above ¥50,000 is ¥500 + 4% of the amount'
      },
      {
        icon: 'marketing/pricing/credit-card.svg',
        label: 'Auto-pay',
        text: 'With your permission, we can use your credit card to order or pay for things on your behalf.'
      },
      {
        icon: 'marketing/pricing/translation.svg',
        label: 'On-demand translation',
        text: 'Get your documents translated from Japanese to English, on demand.'
      },
      {
        icon: 'marketing/pricing/add-hours.svg',
        label: 'Quick Response',
        text: 'First response within 2~3 hours of your message, with an ETA for task completion. If it ends up taking more time, the VA will keep in touch to update on any changes to the ETA.'
      },
      {
        icon: 'marketing/pricing/communicate.svg',
        label: 'We communicate where you do',
        text: 'Communicate with your assistant in the format you’re most comfortable. Text, iMessage, email, Slack, etc. You choose.'
      },
      {
        icon: 'marketing/pricing/security.svg',
        label: 'Data security & privacy',
        text: 'We take your data and privacy extremely seriously. All MailMate staff and virtual assistants sign confidentiality agreements.',
        business: true
      }
    ]
  end

  def assistant_comparisons
    [
      {
        label: 'Essentials',
        features: [
          { key: :hours_included, label: "Assistant Hours Included" },
          { key: :addon_hours_available, label: "Add-on Hours Available" },
          { key: :bilingual, label: "Simultaneous Bilingual Interpretation" },
          { key: :dedicated_assistant, label: "Dedicated Assistant" },
        ]
      },
      {
        label: 'Tasks',
        features: [
          { key: :personal_tasks, label: "Personal Tasks" },
          { key: :business_tasks, label: "Business Tasks" },
          { key: :access_accounts, label: "Access Accounts" },
          { key: :task_priorization_allowed, label: "Task Priorization" }
        ]
      },
      {
        label: 'Bills',
        features: [
          { key: :pay_bills, label: "Pay Bills on Demand" },
          { key: :just_charge_me, label: "Just Charge Me" }
        ]
      },
      {
        label: 'Communication',
        features: [
          { key: :communication_dashboard, label: "MailMate Dashboard" },
          { key: :communication_email, label: "Email" },
          { key: :communication_chat_apps, label: "Chat Apps" },
          { key: :communication_phone, label: "Phone" },
        ]
      },
      {
        label: 'For Businesses',
        features: [
          { key: :company_address, label: "Register Company Address" },
          { key: :custom_nda, label: "Custom NDA" },
        ]
      },
      {
        label: 'Add Ons',
        features: [
          { key: :virtual_reception, label: "Virtual Reception Service" },
          { key: :in_person_support, label: "In-Person Support in Japan" }
        ]
      }
    ]
  end

  def assistant_why_choose_us
    [
      {
        icon: 'marketing/pricing/quality.svg',
        label: 'Quick Discovery Call',
        text: 'Tell us the specifics of your needs and requirements. We will let you know the estimated time for you to start working with your assistant.'
      },
      {
        icon: 'marketing/pricing/launch.svg',
        label: 'Sign Up To MailMate',
        text: 'Once your assistant is ready, you can sign up to a MailMate plan! MailMate accepts all major credit cards. Payments are processed with Stripe.'
      },
      {
        icon: 'marketing/pricing/response-time.svg',
        label: 'Onboarding Phone Call',
        text: 'Have an onboarding call with your assistant, clarify upcoming tasks and ask questions. Up to 30 min. of complimentary time to facilitate a great start.'
      }
    ]
  end

  # MARK: Mail

  def mail_comparisons
    [
      {
        label: 'Feature Breakdown',
        label_jp: '機能一覧：',
        features: [
          { key: :virtual_address, label: "Your own virtual address in Japan", label_jp: "郵便物の転送先住所" },
          { key: :free_cloud_storage, label: "Free cloud storage of digitized mail", label_jp: "スキャンされた郵便物の クラウド保管ストレージ" },
          { key: :secure_mail_disposal, label: "Secure mail disposal when requested", label_jp: "指示に応じた郵便物の セキュア廃棄" },
          { key: :email_notifications, label: "Email notification for received mail", label_jp: "指定されたメールアドレスへの郵便物受け取り通知" },
          { key: :unlimited_envelope_scans, label: "Unlimited outside-envelope-only scans", label_jp: "無開封スキャン（封筒のみをスキャン）" },
          { key: :multiple_access_accounts, label: "Multiple access accounts", label_jp: "複数のユーザーアカウント" },
          { key: :mail_forwarding, label: "Mail forwarding *", label_jp: "郵便物の転送 *" },
          { key: :monthly_content_scans, label: "Included content scans **", label_jp: "料金に含まれる 開封スキャン件数 **" },
          { key: :monthly_translation_summaries, label: "Translation summary of scanned content***", label_jp: "開封スキャンした郵便物の日>英翻訳サマリー　***" },
          { key: :pay_bills, label: "We'll pay your bills as requested ****", label_jp: "支払い代行サービス ****" },
          { key: :register_corporate_address, label: "Register your corporate address", label_jp: '法人登記に MailMate住所を利用' }
        ]
      }
    ]
  end

  def mail_why_choose_us
    [
      {
        icon: 'marketing/pricing/response-time.svg',
        label: 'We do all the work for you',
        text: 'You don’t have the time to jump through hoops. That’s why we do everything for you. From scanning, translating, and securely storing—to shredding and even paying your bills.',
        label_jp: '面倒な郵便周りを一括で代行支援',
        text_jp: '日々忙しいあなたの為に、私たちが煩雑な郵便タスクを代行します。スキャン、簡易翻訳、セキュアで検索可能な保管管理、セキュアな書類廃棄、そして支払い通知書の支払い代行まで。',
      },
      {
        icon: 'marketing/pricing/support.svg',
        label: 'Superior customer support',
        text: 'If you ever have any questions, our digital mailroom customer service team are the best in the business. And, most importantly, they all speak fluent English.',
        label_jp: '優れたカスタマーサポート',
        text_jp: 'MailMateのカスタマーサポートのチームは、優秀なスタッフで構成されています。',
      },
      {
        icon: 'marketing/pricing/data-security.svg',
        label: 'Security focused',
        text: 'Security is our #1 priority. All your mail stays under 24/7 surveillance or can be shredded to ensure your privacy. Once your mail is digitally converted, it’s encrypted with 256-bit encryption level technology.',
        label_jp: 'セキュリティ重視',
        text_jp: 'セキュリティは私たちの最優先事項です。お客様の郵便物はすべて24時間365日監視され、依頼された場合はセキュアに書類廃棄します。郵便物は電子化された後、256ビットの暗号化レベルの技術で暗号化されます。',
      },
      {
        icon: 'marketing/pricing/flexibility.svg',
        label: 'Absolute flexibility',
        text: 'Whether you’re in the office, travelling the globe, or drinking cocktails on the beach, you’ll always have 100% access to all your mail and documents.',
        label_jp: 'かつてない柔軟性をもたらす',
        text_jp: 'オフィスにいても、世界中を旅していても、ビーチでカクテルを飲んでいても、すべての郵便物と書類をいつでもアクセス＆対応可能になります。',
      }
    ]
  end
end
