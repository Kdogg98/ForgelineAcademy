import {
  ShieldCheck,
  FileText,
  AlertTriangle,
  Hexagon,
  ArrowLeft,
} from 'lucide-react';
import type { Route } from '@/components/Nav';

type LegalDoc = 'privacy' | 'terms' | 'disclaimer';

interface LegalProps {
  doc: LegalDoc;
  onNavigate: (r: Route) => void;
}

const META: Record<
  LegalDoc,
  { title: string; subtitle: string; icon: typeof ShieldCheck; badge: string }
> = {
  privacy: {
    title: 'Privacy Policy',
    subtitle: 'How we collect, use, and protect your information',
    icon: ShieldCheck,
    badge: 'Privacy',
  },
  terms: {
    title: 'Terms of Service',
    subtitle: 'The terms that govern your use of ForgeLine Academy',
    icon: FileText,
    badge: 'Terms',
  },
  disclaimer: {
    title: 'Training Disclaimer',
    subtitle: 'Important limitations of our training content',
    icon: AlertTriangle,
    badge: 'Disclaimer',
  },
};

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="mb-8">
      <h2 className="font-display text-lg font-semibold text-white mb-3">{title}</h2>
      <div className="text-sm text-steel-300 leading-relaxed space-y-3">{children}</div>
    </section>
  );
}

function LastUpdated() {
  return (
    <p className="text-xs text-steel-500 italic mb-8">
      Last updated: August 13, 2026
    </p>
  );
}

function PrivacyContent() {
  return (
    <>
      <LastUpdated />
      <Section title="1. Overview">
        <p>
          ForgeLine Academy (&ldquo;we,&rdquo; &ldquo;us,&rdquo; or &ldquo;ForgeLine&rdquo;)
          operates a web-based industrial maintenance training platform. This Privacy
          Policy explains what information we collect, how we use it, and the choices
          you have. By creating an account or using the platform, you consent to the
          practices described here.
        </p>
      </Section>
      <Section title="2. Information We Collect">
        <p><strong className="text-steel-100">Account information:</strong> When you register, we collect your email address and a password (stored as a salted hash, never in plain text). Your display name, if provided, is also stored.</p>
        <p><strong className="text-steel-100">Learning data:</strong> We track which lessons you complete, quiz scores, certificates earned, and course progress. This data is linked to your account so you can resume training across devices.</p>
        <p><strong className="text-steel-100">Usage data:</strong> We log page views, session duration, and feature interactions to improve the platform and diagnose technical issues.</p>
        <p><strong className="text-steel-100">Admin records:</strong> If you are granted an admin role, we store that role assignment and any administrative actions you perform.</p>
      </Section>
      <Section title="3. How We Use Your Information">
        <p>We use your information to:</p>
        <ul className="list-disc list-inside space-y-1.5 pl-2">
          <li>Provide and maintain your account, course progress, and certificates.</li>
          <li>Display your dashboard, learning path recommendations, and completion status.</li>
          <li>Communicate with you about your account, course updates, and platform changes.</li>
          <li>Detect, prevent, and address technical issues, fraud, or abuse.</li>
          <li>Compile aggregate, de-identified analytics to improve course content and platform usability.</li>
        </ul>
      </Section>
      <Section title="4. How We Share Your Information">
        <p>
          We do not sell your personal information. We share data only in these
          limited circumstances:
        </p>
        <ul className="list-disc list-inside space-y-1.5 pl-2">
          <li><strong className="text-steel-100">Service providers:</strong> We use Supabase for database hosting and authentication. These providers process your data under their own privacy and security policies, solely to deliver services on our behalf.</li>
          <li><strong className="text-steel-100">Legal obligations:</strong> If required by law, court order, or government regulation, we may disclose information necessary to comply.</li>
          <li><strong className="text-steel-100">Business transfer:</strong> In the event of a merger, acquisition, or asset sale, user data may transfer to the acquiring entity, subject to the protections in this policy.</li>
        </ul>
      </Section>
      <Section title="5. Data Security">
        <p>
          We protect your data using industry-standard practices: encrypted password
          hashing, row-level security on all database tables, and scoped access
          policies that ensure each user can only read or modify their own data.
          Admin-level actions require an explicitly assigned admin role. No method of
          transmission or storage is 100% secure, but we work to protect your
          information using reasonable technical and organizational measures.
        </p>
      </Section>
      <Section title="6. Your Rights and Choices">
        <p><strong className="text-steel-100">Access and portability:</strong> You can view your account information and learning progress at any time from your dashboard.</p>
        <p><strong className="text-steel-100">Update information:</strong> You can update your display name or password from your account settings.</p>
        <p><strong className="text-steel-100">Account deletion:</strong> You may request deletion of your account and associated data by contacting us. We will remove your personal data within a reasonable timeframe, subject to legal retention requirements.</p>
        <p><strong className="text-steel-100">Marketing:</strong> You may opt out of promotional emails at any time using the unsubscribe link in any email.</p>
      </Section>
      <Section title="7. Data Retention">
        <p>
          We retain your account information and learning data for as long as your
          account is active. If you delete your account, we remove or anonymize your
          personal data within 90 days, except where retention is required by law
          (such as records of certificate issuance or fraud prevention).
        </p>
      </Section>
      <Section title="8. Children's Privacy">
        <p>
          ForgeLine Academy is designed for industrial maintenance professionals and
          is not directed at children under 16. We do not knowingly collect personal
          information from anyone under 16. If you believe a minor has registered,
          please contact us and we will delete the account.
        </p>
      </Section>
      <Section title="9. Cookies and Local Storage">
        <p>
          We use browser local storage and session tokens to keep you logged in and
          remember your progress. We do not use third-party advertising cookies. Any
          analytics we collect are first-party and used solely to improve the platform.
        </p>
      </Section>
      <Section title="10. Changes to This Policy">
        <p>
          We may update this Privacy Policy from time to time. When we do, we will
          revise the &ldquo;Last updated&rdquo; date at the top of this page. For
          material changes, we will provide a prominent notice on the platform. Your
          continued use of ForgeLine Academy after any change constitutes acceptance
          of the updated policy.
        </p>
      </Section>
      <Section title="11. Contact">
        <p>
          If you have questions about this Privacy Policy or your personal data,
          contact us at <span className="text-rok-400">privacy@forgelineacademy.com</span>.
        </p>
      </Section>
    </>
  );
}

function TermsContent() {
  return (
    <>
      <LastUpdated />
      <Section title="1. Acceptance of Terms">
        <p>
          By creating an account, signing in, or otherwise using ForgeLine Academy
          (the &ldquo;Platform&rdquo;), you agree to be bound by these Terms of
          Service. If you do not agree, do not use the Platform.
        </p>
      </Section>
      <Section title="2. Description of Service">
        <p>
          ForgeLine Academy provides web-based industrial maintenance and controls
          training courses, quizzes, progress tracking, and certificates of
          completion. The Platform offers free access to Mechanical and Electrical
          course content and paid Premium access to Instrumentation &amp; Electrical
          and Engineering / Advanced Controls content.
        </p>
      </Section>
      <Section title="3. Account Registration and Responsibilities">
        <p>
          You must provide accurate registration information and keep your password
          secure. You are responsible for all activity under your account and must
          not share your credentials. If you suspect unauthorized access, notify us
          immediately.
        </p>
        <p>
          You must be at least 16 years old to create an account. If you are using
          the Platform on behalf of an employer or organization, you represent that
          you have authority to bind that organization to these Terms.
        </p>
      </Section>
      <Section title="4. Acceptable Use">
        <p>You agree not to:</p>
        <ul className="list-disc list-inside space-y-1.5 pl-2">
          <li>Use the Platform for any unlawful purpose or in violation of any local, state, national, or international law.</li>
          <li>Attempt to access another user&apos;s account, data, or progress.</li>
          <li>Reverse engineer, decompile, scrape, or otherwise extract course content or platform data.</li>
          <li>Redistribute, resell, or republish course lessons, quizzes, study notes, or certificates without written permission.</li>
          <li>Upload viruses, malware, or any code intended to disrupt the Platform.</li>
          <li>Use automated scripts or bots to interact with the Platform beyond normal personal use.</li>
        </ul>
      </Section>
      <Section title="5. Intellectual Property and License">
        <p>
          All course content — including lessons, quizzes, study notes, diagrams,
          certificates, and platform design — is owned by ForgeLine Academy and is
          protected by copyright and other intellectual property laws. Your
          enrollment grants you a limited, non-exclusive, non-transferable,
          revocable license to access and view the content for your personal
          learning during the term of your account.
        </p>
        <p>
          You may download study notes and certificates for your own reference and
          professional portfolio. You may not remove watermarks, attribution, or
          copyright notices from any content.
        </p>
      </Section>
      <Section title="6. Premium Subscriptions">
        <p>
          Premium access is offered as a monthly subscription. Subscriptions renew
          automatically until cancelled. You can cancel at any time from your account
          settings; cancellation takes effect at the end of the current billing
          period. Fees are non-refundable except where required by law.
        </p>
        <p>
          We may change subscription fees with reasonable advance notice. Any price
          change takes effect at the start of your next billing cycle following
          notice.
        </p>
      </Section>
      <Section title="7. Certificates of Completion">
        <p>
          Certificates are issued when you complete all lessons in a course and pass
          all quizzes at the required threshold. A certificate of completion
          acknowledges that you have finished the course material on this Platform.
          It is <strong className="text-steel-100">not</strong> a professional
          license, trade certification, journeyman card, or credential recognized
          by any regulatory body. See our Training Disclaimer for full details.
        </p>
      </Section>
      <Section title="8. User Conduct and Prohibited Content">
        <p>
          If the Platform allows user-generated content (such as profile
          information), you retain ownership of that content but grant ForgeLine a
          worldwide, royalty-free license to host, display, and use it in connection
          with the Platform. You must not submit content that is unlawful,
          defamatory, infringing, or harmful.
        </p>
      </Section>
      <Section title="9. Termination">
        <p>
          You may delete your account at any time. We may suspend or terminate your
          account if you violate these Terms, if your account is inactive for more
          than 12 months, or if we discontinue the Platform. Upon termination, your
          right to access course content ends immediately.
        </p>
      </Section>
      <Section title="10. Disclaimers">
        <p>
          The Platform and all content are provided &ldquo;as is&rdquo; and
          &ldquo;as available&rdquo; without warranties of any kind. We do not
          guarantee that the Platform will be uninterrupted, error-free, or secure.
          Our training content is for educational purposes only and does not
          replace site-specific procedures, OEM manuals, or required certifications.
          See our Training Disclaimer for full details.
        </p>
      </Section>
      <Section title="11. Limitation of Liability">
        <p>
          To the maximum extent permitted by law, ForgeLine Academy and its
          operators shall not be liable for any indirect, incidental, special,
          consequential, or punitive damages — including loss of profits, data,
          business, or goodwill — arising from your use of or inability to use the
          Platform. Our total liability for any claim shall not exceed the amount
          you paid us in the 12 months preceding the claim.
        </p>
      </Section>
      <Section title="12. Indemnification">
        <p>
          You agree to indemnify and hold harmless ForgeLine Academy and its
          operators from any claims, damages, or expenses (including reasonable
          legal fees) arising from your use of the Platform, your violation of
          these Terms, or your infringement of any third-party rights.
        </p>
      </Section>
      <Section title="13. Governing Law">
        <p>
          These Terms shall be governed by and construed in accordance with the laws
          of the jurisdiction in which ForgeLine Academy operates, without regard
          to conflict-of-law principles. Any disputes shall be resolved in the
          courts of that jurisdiction.
        </p>
      </Section>
      <Section title="14. Changes to These Terms">
        <p>
          We may modify these Terms from time to time. When we do, we will revise
          the &ldquo;Last updated&rdquo; date and provide notice on the Platform for
          material changes. Your continued use after any change constitutes
          acceptance of the updated Terms.
        </p>
      </Section>
      <Section title="15. Contact">
        <p>
          If you have questions about these Terms, contact us at{' '}
          <span className="text-rok-400">legal@forgelineacademy.com</span>.
        </p>
      </Section>
    </>
  );
}

function DisclaimerContent() {
  return (
    <>
      <LastUpdated />
      <div className="mb-8 p-5 rounded-lg bg-warning-500/10 border border-warning-500/30 flex items-start gap-3">
        <AlertTriangle className="w-5 h-5 text-warning-400 shrink-0 mt-0.5" />
        <p className="text-sm text-steel-200 leading-relaxed">
          <strong className="text-warning-300">Read this carefully.</strong> The
          training provided by ForgeLine Academy is for educational purposes only.
          It does not replace your facility&apos;s procedures, OEM equipment
          manuals, or any required license, certification, or qualification.
        </p>
      </div>

      <Section title="1. Not a License or Certification">
        <p>
          ForgeLine Academy does <strong className="text-steel-100">not</strong>{' '}
          license, certify, or qualify anyone to perform work on industrial
          equipment. Completing a course and receiving a certificate of completion
          does not grant you any trade license, journeyman status, professional
          engineering credential, electrical license, or other legally recognized
          qualification. Our certificates acknowledge course completion only.
        </p>
        <p>
          Any work on industrial equipment — electrical, mechanical, instrumentation,
          or controls — may require specific licenses, certifications, or permits
          depending on your jurisdiction, industry, and employer. You are solely
          responsible for determining what credentials are required and for
          obtaining them from the appropriate authority.
        </p>
      </Section>

      <Section title="2. Not a Replacement for Plant-Level Requirements">
        <p>
          Every industrial facility has its own safety procedures, lockout/tagout
          (LOTO) programs, permit systems, operating procedures, and equipment-specific
          instructions. ForgeLine Academy&apos;s training content is general and
          educational. It is <strong className="text-steel-100">not</strong> a
          substitute for:
        </p>
        <ul className="list-disc list-inside space-y-1.5 pl-2">
          <li>Your site&apos;s lockout/tagout (LOTO) procedures and energy isolation policies.</li>
          <li>Your facility&apos;s safe work permits, hot work permits, and confined space entry procedures.</li>
          <li>OEM equipment manuals, technical data sheets, and manufacturer service bulletins.</li>
          <li>Your employer&apos;s standard operating procedures (SOPs) and job safety analyses (JSAs).</li>
          <li>Site-specific PPE requirements and arc flash boundary calculations.</li>
          <li>Local, state, or federal regulations including OSHA, NFPA, NEC, NESC, and similar standards.</li>
          <li>Any internal training, qualification, or authorization process required by your employer before you may perform work.</li>
        </ul>
        <p>
          <strong className="text-steel-100">Always follow your site&apos;s
          procedures first.</strong> If anything in our training conflicts with
          your facility&apos;s requirements, your facility&apos;s requirements
          govern. Never bypass, override, or disregard a site procedure based on
          content from this Platform.
        </p>
      </Section>

      <Section title="3. Safety Is Your Responsibility">
        <p>
          Industrial maintenance and controls work involves serious hazards:
          electrical shock, arc flash, mechanical energy, stored energy, rotating
          equipment, high pressure, hazardous chemicals, and working at heights.
          The safety information in our courses is general guidance, not a complete
          safety program.
        </p>
        <p>
          Before performing any work, you must:
        </p>
        <ul className="list-disc list-inside space-y-1.5 pl-2">
          <li>Follow your site&apos;s LOTO procedure to isolate all energy sources.</li>
          <li>Verify zero energy state before touching equipment.</li>
          <li>Wear all required PPE as specified by your site and the task.</li>
          <li>Use properly rated and calibrated test equipment.</li>
          <li>Work only within your training, qualifications, and site authorization.</li>
          <li>Stop and consult a qualified supervisor if anything is unclear or unsafe.</li>
        </ul>
      </Section>

      <Section title="4. No Warranty of Accuracy or Completeness">
        <p>
          While we strive to produce accurate, high-quality training content,
          industrial standards, codes, and best practices change over time. We do
          not warrant that any lesson, quiz, or study note is error-free, current,
          or applicable to your specific equipment or facility. Always verify
          critical information against current OEM documentation and applicable
          codes before acting on it.
        </p>
      </Section>

      <Section title="5. No Liability for Actions Taken">
        <p>
          ForgeLine Academy, its operators, instructors, and content contributors
          are not liable for any injury, property damage, equipment failure,
          regulatory violation, or other loss arising from the application of
          training content in a real-world setting. You assume all risk for any
          work you perform based on or influenced by content from this Platform.
        </p>
      </Section>

      <Section title="6. Employer and Supervisor Responsibility">
        <p>
          If you are an employer, supervisor, or training coordinator using
          ForgeLine Academy as part of your team&apos;s development, you remain
          responsible for:
        </p>
        <ul className="list-disc list-inside space-y-1.5 pl-2">
          <li>Verifying that each worker is properly licensed, certified, and authorized before assigning work.</li>
          <li>Ensuring all site-specific safety procedures, LOTO programs, and permits are in place and followed.</li>
          <li>Confirming that workers understand the difference between completing an online course and being qualified to perform a task on your equipment.</li>
          <li>Providing hands-on training, mentorship, and supervision appropriate to the task and the worker&apos;s experience level.</li>
        </ul>
        <p>
          ForgeLine Academy is a supplementary training tool. It does not replace
          your facility&apos;s internal qualification process.
        </p>
      </Section>

      <Section title="7. Content May Be Updated">
        <p>
          We may update, revise, or remove course content at any time to reflect
          changing standards, new information, or platform improvements. Completed
          courses and earned certificates reflect the content as it existed at the
          time of completion. We are not obligated to notify users of every content
          change, but we will make reasonable efforts to communicate material
          updates.
        </p>
      </Section>

      <Section title="8. Contact">
        <p>
          If you have questions about this Training Disclaimer, contact us at{' '}
          <span className="text-rok-400">legal@forgelineacademy.com</span>.
        </p>
      </Section>
    </>
  );
}

export function Legal({ doc, onNavigate }: LegalProps) {
  const meta = META[doc];
  const Icon = meta.icon;

  return (
    <div className="pt-16 min-h-screen">
      <div className="border-b border-steel-700/60 bg-navy-950/40">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 py-10">
          <button
            onClick={() => onNavigate({ name: 'home' })}
            className="inline-flex items-center gap-1.5 text-sm text-steel-400 hover:text-rok-400 transition-colors mb-6"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to home
          </button>
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-accent-500/10 border border-accent-500/30 text-accent-300 text-xs font-semibold uppercase tracking-wider mb-4">
            <Icon className="w-3.5 h-3.5" />
            {meta.badge}
          </div>
          <h1 className="font-display text-3xl sm:text-4xl font-bold text-white mb-2">
            {meta.title}
          </h1>
          <p className="text-steel-400 max-w-2xl">{meta.subtitle}</p>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 py-12">
        <div className="card p-8 sm:p-10">
          {doc === 'privacy' && <PrivacyContent />}
          {doc === 'terms' && <TermsContent />}
          {doc === 'disclaimer' && <DisclaimerContent />}
        </div>

        <div className="mt-8 flex flex-wrap items-center justify-center gap-4 text-sm">
          {doc !== 'privacy' && (
            <button
              onClick={() => onNavigate({ name: 'legal', doc: 'privacy' })}
              className="text-steel-400 hover:text-rok-400 transition-colors"
            >
              Privacy Policy
            </button>
          )}
          {doc !== 'terms' && (
            <button
              onClick={() => onNavigate({ name: 'legal', doc: 'terms' })}
              className="text-steel-400 hover:text-rok-400 transition-colors"
            >
              Terms of Service
            </button>
          )}
          {doc !== 'disclaimer' && (
            <button
              onClick={() => onNavigate({ name: 'legal', doc: 'disclaimer' })}
              className="text-steel-400 hover:text-rok-400 transition-colors"
            >
              Training Disclaimer
            </button>
          )}
        </div>

        <div className="mt-10 pt-6 border-t border-steel-700/40 flex items-center justify-center gap-2">
          <Hexagon className="w-5 h-5 text-rok-500" strokeWidth={1.6} />
          <span className="text-xs text-steel-500">
            &copy; {new Date().getFullYear()} ForgeLine Academy. Built for the plant floor.
          </span>
        </div>
      </div>
    </div>
  );
}
