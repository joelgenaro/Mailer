# Plans for Mail service
# These were introduced in October 2021 (thus V2)
class Mail::PricingPlansV2 < Billing::PricingPlans
    def self.all
      {
         # Mail • Starter Plan
         mail_starter: {
          title: 'Starter',
          title_jp: 'スターター',
          price: 3800,
          stripe_price_id: {
            test: '',
            live: ''
          },
          content: {
            type: 'individual',
            most_popular: false,
            description: 'Ideal for personal use: your virtual mailbox in Japan. Just the basics for receiving, storing, and forwarding your Japanese mail. At your request, we scan, translate, and pay bills.',
            description_jp: '個人利用に最適。
  
            郵便物の受取代行、無開封スキャン、保管、転送するためのミニマムプラン。
            
            都度有料オプションで、郵便物中身のスキャン、簡易翻訳、支払い代行も対応可能。
            ',
            whats_included: [
              'Your own virtual address in Japan',
              'Free cloud storage of digitized mail',
              'Secure mail disposal when requested',
              'Email notification for received mail',
            ],
            whats_included_jp: [
              '郵便物の転送先住所',
              'ご指定されたメールアドレスへの郵便物受け取り通知メール',
              '電子化された郵便物コンテンツの無料クラウド保管',
              'ご希望に応じて郵便物のセキュアな廃棄'
            ],
            comparison_features: {
              virtual_address: true,
              free_cloud_storage: true,
              secure_mail_disposal: true,
              email_notifications: true,
              unlimited_envelope_scans: true,
              multiple_access_accounts: true,
              mail_forwarding: true,
              monthly_content_scans: '0',
              monthly_translation_summaries: 0,
              pay_bills: true,
              register_corporate_address: false,
              audit_trail: false,
            }
          },
          configuration: {
            scope: 'en',
            require_consultation: false,
            monthly_content_scans: 0,
            monthly_translation_summaries: 0,
            pay_bills: true,
            audit_trail: false
          }
        },
        # Mail • Basic Plan
        mail_basic: {
          title: 'Basic',
          title_jp: 'ベーシック',
          price: 9800,
          stripe_price_id: {
            test: '',
            live: ''
          },
          content: {
            type: 'individual',
            most_popular: true,
            description: 'For the digital nomad or sole entrepreneur, a Japan business address for company incorporation. Get your physical mail digitized and translated summaries with 1-click.',
            description_jp: '
              フリーランサー、デジタルノマド、個人事業主などのビジネス利用向け。
  
              法人登記用にもMailMate住所を利用可能。郵便物の開封スキャン、ワンクリックで翻訳サマリーも依頼可能。
            ',
            whats_included: [
              'Your own virtual address in Japan',
              'Email notification for received mail',
              '15 mail scans included per month',
              '15 translation summaries included per month',
              'Register your corporate address',            
            ],
            whats_included_jp: [
              '郵便物の転送先住所',
              'ご指定されたメールアドレスへの郵便物受け取り通知メール',
              '電子化された郵便物コンテンツの無料クラウド保管',
              'ご希望に応じて郵便物のセキュアな廃棄',
              '月15通までの開封スキャン',
              '月15通までの翻訳サマリー',
              '法人登記用にMailMate住所を利用可能',
            ],
            comparison_features: {
              virtual_address: true,
              free_cloud_storage: true,
              secure_mail_disposal: true,
              email_notifications: true,
              unlimited_envelope_scans: true,
              multiple_access_accounts: true,
              mail_forwarding: true,
              monthly_content_scans: '15 p/mo',
              monthly_translation_summaries: '15 p/mo',
              pay_bills: true,
              register_corporate_address: true,
              audit_trail: false,
            }
          },
          configuration: {
            scope: 'en',
            require_consultation: false,
            monthly_content_scans: 15,
            monthly_translation_summaries: 15,
            pay_bills: true,
            audit_trail: false
          }
        },
        # Mail • Standard Plan
        mail_standard: {
          title: 'Standard',
          title_jp: 'スタンダード',
          price: 28000,
          stripe_price_id: {
            test: '',
            live: ''
          },
          content: {
            type: 'business',
            most_popular: false,
            description: 'For small teams with mid to high mail volume. Get an upscale Japan business address and bilingual virtual mailbox service. More mail scans & translated summaries included.',
            description_jp: '
            毎月数十件以上の郵便物を受け取る小規模チームに向け。
  
            法人登記用にもMailMate住所を利用可能。郵便物の開封スキャン、ワンクリックで翻訳サマリーも依頼可能。          
            ',
            whats_included: [
              'Your own virtual address in Japan',
              'Email notification for received mail',
              '60 mail scans included per month',
              '60 translation summaries included per month',
              'Register your corporate address',            
            ],
            whats_included_jp: [
              '郵便物の転送先住所',
              'ご指定されたメールアドレスへの郵便物受け取り通知メール',
              '電子化された郵便物コンテンツの無料クラウド保管',
              'ご希望に応じて郵便物のセキュアな廃棄',
              '月60通までの開封スキャン',
              '月60通までの翻訳サマリー',
              '法人登記用にMailMate住所を利用可能',
            ],
            comparison_features: {
              virtual_address: true,
              free_cloud_storage: true,
              secure_mail_disposal: true,
              email_notifications: true,
              unlimited_envelope_scans: true,
              multiple_access_accounts: true,
              mail_forwarding: true,
              monthly_content_scans: '60 p/mo',
              monthly_translation_summaries: '60 p/mo',
              pay_bills: true,
              register_corporate_address: true,
              audit_trail: false
            }
          },
          configuration: {
            scope: 'en',
            require_consultation: false,
            monthly_content_scans: 60,
            monthly_translation_summaries: 60,
            pay_bills: true,
            audit_trail: false
          }
        },
        # Mail • Pro Plan
        mail_pro: {
          title: 'Pro',
          title_jp: 'プロ',
          price: 88000,
          stripe_price_id: {
            test: '',
            live: ''
          },
          content: {
            type: 'business',
            most_popular: false,
            description: 'For SMEs, focus on your business and let us handle the paperwork with this mail-handling plan designed for remote teams. Report to global HQ with our translated summaries.',
            description_jp: '
              毎月100件以上の郵便物を受け取る中堅中小企業向け。
  
              郵便物の確認のためだけに定期的に出社する必要をなくし、郵便物の対応内容に応じて適切な役職者にスピーディーに書類のスキャンデータを転送したり、処理スピードを劇的に短縮し、対応抜け漏れ防止にも効果的。
            ',
            whats_included: [
              'Your own virtual address in Japan',
              'Email notification for received mail',
              '110 mail scans included per month',
              '110 translation summaries included per month',
              'Register your corporate address'
            ],
            whats_included_jp: [
              '郵便物の転送先住所',
              'ご指定されたメールアドレスへの郵便物受け取り通知メール',
              '電子化された郵便物コンテンツの無料クラウド保管',
              'ご希望に応じて郵便物のセキュアな廃棄',
              '月110通までの開封スキャン',
              '月110通までの翻訳サマリー',
              '法人登記用にMailMate住所を利用可能',
            ],
            comparison_features: {
              virtual_address: true,
              free_cloud_storage: true,
              secure_mail_disposal: true,
              email_notifications: true,
              unlimited_envelope_scans: true,
              multiple_access_accounts: true,
              mail_forwarding: true,
              monthly_content_scans: '110 p/mo',
              monthly_translation_summaries: '110 p/mo',
              pay_bills: true,
              register_corporate_address: true,
              audit_trail: true,
            }
          },
          configuration: {
            scope: 'en',
            require_consultation: false,
            monthly_content_scans: 110,
            monthly_translation_summaries: 110,
            pay_bills: true,
            audit_trail: true
          }
        },
        # Mail • JA Standard
        mail_ja_standard: {
          title: 'Standard',
          title_jp: 'スタンダード',
          price: 1500,
          stripe_price_id: {
            test: '',
            live: ''
          },
          content: {},
          configuration: {
            scope: 'ja',
            require_consultation: false,
            monthly_content_scans: 5,
            monthly_translation_summaries: 0,
            pay_bills: true,
            audit_trail: false
          }
        },
        # Mail • JA Premium
        mail_ja_premium: {
          title: 'Premium',
          title_jp: 'プレミアム',
          price: 3800,
          stripe_price_id: {
            test: '',
            live: ''
          },
          content: {},
          configuration: {
            scope: 'ja',
            require_consultation: false,
            monthly_content_scans: 25,
            monthly_translation_summaries: 0,
            pay_bills: true,
            audit_trail: false
          }
        },
        # Mail • JA Business
        mail_ja_business: {
          title: 'Business',
          title_jp: 'ビジネス',
          price: 9800,
          stripe_price_id: {
            test: '',
            live: ''
          },
          content: {},
          configuration: {
            scope: 'ja',
            require_consultation: false,
            monthly_content_scans: 60,
            monthly_translation_summaries: 0,
            pay_bills: true,
            audit_trail: false
          }
        }
      }
    end
  end
