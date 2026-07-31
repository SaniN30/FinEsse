-- Job-Ready tier: first real lesson track. Previously Job-Ready had zero
-- lessons -- only the 9 interview-practice questions seeded in
-- 00000000000019 (see AGENTS.md's Phase 9 section and the product-gap
-- audit). This adds 3 skills/lessons/quizzes at the same depth as the
-- (now-expanded) School/College content, following the exact schema/RPC
-- pattern those tiers already use -- no schema or RPC changes.
--
-- Prerequisite chain wires off 'financial-statement-modeling' (the most
-- advanced seeded College skill), same pattern College used chaining off
-- School's most advanced skill.

insert into skills (id, tier, slug, title, prerequisite_skill_id, mastery_threshold) values
  ('00000000-0000-0000-0001-000000000201', 'job_ready', 'interview-fundamentals', 'Interview Fundamentals',
    '00000000-0000-0000-0001-000000000104', 0.8),
  ('00000000-0000-0000-0001-000000000202', 'job_ready', 'resume-and-behavioral-basics', 'Resume & Behavioral Basics',
    '00000000-0000-0000-0001-000000000201', 0.8),
  ('00000000-0000-0000-0001-000000000203', 'job_ready', 'case-method-basics', 'Case-Method Basics',
    '00000000-0000-0000-0001-000000000202', 0.8);

insert into lessons (id, skill_id, content_type, content_body, order_index) values
  ('00000000-0000-0000-0002-000000000201', '00000000-0000-0000-0001-000000000201', 'article',
   'A job interview has one core purpose: giving the interviewer enough evidence, in a short window, to believe you can do the job and will work well with the team. Most interviews mix a few question types -- behavioral ("tell me about a time..."), technical (testing job-specific knowledge), and fit ("why this company?") -- and each type wants a different kind of answer, so recognising which type a question is comes before answering it well.

A common mistake is answering every question the same way regardless of type: giving a vague, general answer to a behavioral question that needed a specific story, or giving a rambling personal anecdote to a technical question that needed a precise, structured explanation. Preparing means having a few real stories ready for behavioral questions and being able to explain core concepts clearly and concisely for technical ones -- not memorising a single script for everything.

Worked example: asked "Tell me about a time you handled a disagreement" (behavioral), a weak answer is abstract -- "I''m good at working with people and always try to see other perspectives." A strong answer picks one specific real situation: "On a group project, a teammate and I disagreed on the approach to a deadline. I suggested we each spend 10 minutes outlining our approach, then compared trade-offs together -- we ended up combining both ideas and delivered on time." The second answer gives the interviewer actual evidence, not a claim about yourself.

Recap: identify what type of question you are being asked -- behavioral, technical, or fit -- and answer it in the way that type rewards: specific real stories for behavioral, clear structured explanations for technical, and genuine, researched reasons for fit questions.',
   1),
  ('00000000-0000-0000-0002-000000000202', '00000000-0000-0000-0001-000000000202', 'article',
   'A resume''s job is to get you the interview, not to describe your entire life -- so every line should help a reader quickly see what you can do. The strongest resume bullet points follow a simple pattern: what you did, in what context, with what measurable result -- rather than just listing a responsibility with no evidence of impact.

Behavioral interview answers work best with the same discipline, using a structure often called STAR: Situation (brief context), Task (what needed to happen), Action (what you specifically did), Result (the outcome, ideally with a number or clear before/after). STAR keeps an answer concrete and complete instead of trailing off into vague generalities -- the most common way behavioral answers fail is skipping straight from Situation to a vague Result with no clear Action in between.

Worked example -- weak resume bullet: "Responsible for team project." Strong version, same experience: "Led a 4-person team project under a 2-week deadline; restructured task assignments after week 1 fell behind, and delivered the final report on time with a grade in the top 10% of the class." The strong version shows context (4-person team, 2-week deadline), action (restructured task assignments), and result (on time, top 10%) -- exactly the STAR shape, compressed into one line.

Recap: resume bullets and behavioral answers reward the same underlying discipline -- be specific about context, be clear about what you personally did, and back up the result with something concrete. STAR (Situation, Task, Action, Result) is a reliable structure for building behavioral answers that don''t trail off vaguely.',
   1),
  ('00000000-0000-0000-0002-000000000203', '00000000-0000-0000-0001-000000000203', 'article',
   'Case-method interviews (common in consulting and some finance roles) present an open-ended business problem and evaluate how you think, not just whether you reach the "right" number. The goal is not to guess the interviewer''s expected answer immediately -- it is to structure the problem out loud, state assumptions clearly, and reason toward an estimate step by step.

A reliable structure: (1) clarify the question and restate it in your own words, (2) break the problem into a small number of clear components rather than trying to solve it all at once, (3) make explicit, reasonable assumptions for anything you don''t know and say them out loud, (4) work through the math step by step, narrating your reasoning, (5) sanity-check the final number against something you already know.

Worked example -- "Estimate how many coffees are sold in this city each day." A structured approach: assume the city has 1,000,000 people (state the assumption); assume roughly 30% of the population drinks coffee regularly (another stated assumption) = 300,000 coffee drinkers; assume each drinks an average of 1.2 coffees per day = 360,000 coffees per day. The exact number matters far less than showing clear, sensible assumptions and a step-by-step build-up -- an interviewer evaluating this wants to see the structure, not a memorised fact.

Recap: case questions test structured thinking under uncertainty, not trivia recall. Clarify the question, break it into components, state your assumptions explicitly, work through the math step by step, and sanity-check the result -- that process matters more than landing on any single "correct" number.',
   1);

insert into quizzes (id, skill_id, lesson_id, title, pass_threshold) values
  ('00000000-0000-0000-0003-000000000201', '00000000-0000-0000-0001-000000000201', '00000000-0000-0000-0002-000000000201', 'Interview Fundamentals Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000202', '00000000-0000-0000-0001-000000000202', '00000000-0000-0000-0002-000000000202', 'Resume & Behavioral Basics Quiz', 0.8),
  ('00000000-0000-0000-0003-000000000203', '00000000-0000-0000-0001-000000000203', '00000000-0000-0000-0002-000000000203', 'Case-Method Basics Quiz', 0.8);

insert into quiz_questions (quiz_id, question, options, correct_answer, order_index) values
  -- Interview Fundamentals
  ('00000000-0000-0000-0003-000000000201', 'What are the three common interview question types described in the lesson?',
    '["Behavioral, technical, and fit", "Easy, medium, and hard", "Written, spoken, and timed", "Group, solo, and panel"]'::jsonb,
    'Behavioral, technical, and fit', 1),
  ('00000000-0000-0000-0003-000000000201', 'What is the main problem with answering every interview question the same generic way?',
    '["It is illegal in most interviews", "Different question types reward different kinds of answers, so a one-size-fits-all answer under-delivers on most of them", "It always takes too long to say", "Interviewers cannot tell the difference anyway"]'::jsonb,
    'Different question types reward different kinds of answers, so a one-size-fits-all answer under-delivers on most of them', 2),
  ('00000000-0000-0000-0003-000000000201', 'Asked "Tell me about a time you handled a disagreement," which response is strongest?',
    '["\"I''m good at working with people and always try to see other perspectives.\"", "A specific real story describing the situation, what you did, and the outcome", "Saying you have never disagreed with anyone", "Changing the subject to a technical skill instead"]'::jsonb,
    'A specific real story describing the situation, what you did, and the outcome', 3),
  ('00000000-0000-0000-0003-000000000201', 'You are asked a technical question testing job-specific knowledge. What is the best way to prepare, per the lesson?',
    '["Memorise one script and repeat it regardless of the question", "Be able to explain core concepts clearly and concisely", "Avoid technical questions by changing the topic", "Give a personal anecdote instead of an explanation"]'::jsonb,
    'Be able to explain core concepts clearly and concisely', 4),

  -- Resume & Behavioral Basics
  ('00000000-0000-0000-0003-000000000202', 'What does the STAR structure stand for?',
    '["Situation, Task, Action, Result", "Skills, Talent, Ambition, Results", "Story, Timing, Achievement, Reflection", "Strengths, Talents, Attitude, Résumé"]'::jsonb,
    'Situation, Task, Action, Result', 1),
  ('00000000-0000-0000-0003-000000000202', 'What is the most common way behavioral answers fail, according to the lesson?',
    '["They are too specific", "They skip straight from Situation to a vague Result with no clear Action in between", "They include too many numbers", "They are too short in general"]'::jsonb,
    'They skip straight from Situation to a vague Result with no clear Action in between', 2),
  ('00000000-0000-0000-0003-000000000202', 'Which resume bullet best follows the "context, action, measurable result" pattern?',
    '["\"Responsible for team project.\"", "\"Worked on a project with other people.\"", "\"Led a 4-person team under a 2-week deadline, restructured assignments after falling behind, and delivered on time in the top 10% of the class.\"", "\"Was part of a group.\""]'::jsonb,
    '"Led a 4-person team under a 2-week deadline, restructured assignments after falling behind, and delivered on time in the top 10% of the class."', 3),
  ('00000000-0000-0000-0003-000000000202', 'Why should a resume bullet include a measurable result rather than just listing a responsibility?',
    '["Measurable results are required by law on all resumes", "A responsibility alone gives no evidence of the impact or outcome achieved", "Numbers are the only thing recruiters read", "It makes the resume longer, which is always better"]'::jsonb,
    'A responsibility alone gives no evidence of the impact or outcome achieved', 4),

  -- Case-Method Basics
  ('00000000-0000-0000-0003-000000000203', 'What is the main thing a case-method interview evaluates?',
    '["Whether you know the exact expected answer from memory", "How you structure and reason through an open-ended problem", "How fast you can speak", "Whether you agree with the interviewer''s opinion"]'::jsonb,
    'How you structure and reason through an open-ended problem', 1),
  ('00000000-0000-0000-0003-000000000203', 'In the coffee-estimate worked example, why does stating assumptions like "30% of the population drinks coffee" matter?',
    '["It does not matter -- only the final number is graded", "It makes the reasoning transparent and shows structured thinking, which is what the interviewer is evaluating", "It is required to avoid legal liability", "It guarantees the final number will be exactly correct"]'::jsonb,
    'It makes the reasoning transparent and shows structured thinking, which is what the interviewer is evaluating', 2),
  ('00000000-0000-0000-0003-000000000203', 'A city has 1,000,000 people; assume 30% drink coffee regularly, averaging 1.2 coffees per day each. Roughly how many coffees are sold per day under these stated assumptions?',
    '["30,000", "300,000", "360,000", "1,200,000"]'::jsonb,
    '360,000', 3),
  ('00000000-0000-0000-0003-000000000203', 'What is the recommended first step when given an open-ended case question?',
    '["Immediately state a final numeric answer", "Clarify the question and restate it in your own words", "Ask the interviewer to give you the answer", "Skip straight to complex math"]'::jsonb,
    'Clarify the question and restate it in your own words', 4),
  ('00000000-0000-0000-0003-000000000203', 'Why should you sanity-check your final estimate against something you already know?',
    '["It is not useful -- the exercise ends once you have a number", "It helps catch an unreasonable answer caused by a math or assumption error", "It replaces the need for any assumptions", "It is only relevant for behavioral questions, not case questions"]'::jsonb,
    'It helps catch an unreasonable answer caused by a math or assumption error', 5);
