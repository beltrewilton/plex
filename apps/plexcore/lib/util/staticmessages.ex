defmodule Util.StaticMessages do
  @user_hello_replaced  [
    "I'm excited to express my interest in the available position",
    "I'm writing to inquire about the opportunity to join your team",
    "I'm eager to submit my application for the role",
    "I'm reaching out to express my enthusiasm for the job opening",
    "I'm interested in exploring the possibility of joining your organization"
  ]

  @basic_form  [
    "Almost there to land your job!\nNow, please proceed to the assessment below ⤵️",
    "Just a few steps to your job! 🙌🏼\nYour next step is to fill in the assessment below ⤵️",
    "You're so close to your job!\nThe next task is to tackle the assessment below ⤵️",
    "Your job is just steps away!\nUp next is the assessment, please fill it out below ⤵️",
    "Nearly there! Job is within reach!\nThe next thing to do is fill out the assessment below ⤵️",
    "Steps away from your new job!\nNow, let's move on to the assessment below ⤵️",
    "Job ahead! Just a few steps!\nNext, please complete the assessment below ⤵️",
    "Your job is right around the corner!\nThe following step is to fill out the assessment below ⤵️",
    "Almost at the finish line!\nPlease proceed by filling out the assessment below ⤵️",
    "Just steps from your job!\nNow, kindly complete the assessment below ⤵️"
  ]

  @applicant_assessment_question  [
    %{
      "sentence" =>
        "What are the key communication skills for a phone-based customer service agent?",
      "resume" => "Communication"
    },
    %{
      "sentence" => "How do you stay motivated during long customer service shifts?",
      "resume" => "Motivation"
    },
    %{
      "sentence" => "What strategies do you use to handle a high volume of customer complaints?",
      "resume" => "Conflict"
    },
    %{
      "sentence" =>
        "How do you maintain a positive attitude when dealing with difficult customers?",
      "resume" => "Emotional IQ"
    },
    %{
      "sentence" =>
        "Can you describe a time when you went above and beyond to resolve a customer issue?",
      "resume" => "Problem Solving"
    },
    %{
      "sentence" =>
        "How do you prioritize tasks and manage your time during a busy customer service shift?",
      "resume" => "Time Mgmt"
    },
    %{
      "sentence" =>
        "What do you do to stay up-to-date with product knowledge and company policies?",
      "resume" => "Continuous Learning"
    }
  ]

  @assesment_form  [
    "You've made great progress—well done! 🚀 Next, read the text aloud and send it as a voice note:",
    "You've advanced significantly—congratulations! 🚀 Please read the text aloud and submit it as a voice note:",
    "You've taken a big step forward—kudos! 🚀 In the next step, read the text aloud and send it:",
    "You've made an important leap—awesome job! 🚀 Read the text aloud and send it as a voice note, please:",
    "You've moved ahead impressively—great job! 🚀 Next step: read the text aloud and send it as voice note:",
    "You've achieved a major milestone—congrats! 🚀 Read the following text aloud and send it as a voice message:",
    "You've made remarkable progress—congratulations! 🚀 For the next step, read the text aloud and send it:",
    "You've taken a crucial step forward—nice work! 🚀 Please read aloud the text and send it as a voice note:",
    "You've made significant strides—well done! 🚀 Next, read the following text aloud and send a voice note:",
    "You've moved forward significantly—excellent! 🚀 In the next step, read aloud and send the text as voice note:"
  ]

  @scripted_text  [
    "The resurgence of vinyl records has sparked a debate about the nostalgic appeal of analogue music versus the convenience of digital streaming. While some argue that vinyl's tactile experience enhances musical appreciation, others contend that streaming services provide unparalleled accessibility to diverse genres and artists.",
    "As millennials navigate the gig economy,they must confront the blurred lines between personal and professional brands. Social media influencers, in particular, face the daunting task of maintaining authenticity while monetizing their online presence. Can they escape the stigma of 'selling out' and preserve their artistic integrity?",
    "According to recent studies, millennials prioritize experiential travel, seeking cultural immersion and Instagram-worthy moments over material possessions. This shift in consumer behavior has significant implications for the hospitality industry, as hotels and resorts adapt to cater to the preferences of this tech-savvy demographic.",
    "The concept of micro-influencers has revolutionized the digital marketing landscape. With their niche audiences and high engagement rates, they're becoming increasingly attractive to brands seeking authenticity and precision targeting. As social media algorithms continue to evolve, it's crucial for marketers to adapt and harness the power of these online personalities.",
    "As the world grapples with the complexities of climate change, a new generation of eco-activists is emerging, leveraging social media platforms to mobilize grassroots movements and raise awareness about the urgent need for sustainable practices, while also navigating the intricate web of corporate interests and government policies that often hinder meaningful environmental reform.",
    "The proliferation of virtual reality technology has opened up new avenues for artistic expression, enabling creatives to craft immersive experiences that blur the boundaries between reality and fantasy, but also raises important questions about the impact of this technology on our collective psyche and the potential consequences of becoming increasingly disconnected from the physical world.",
    "In an era where the notion of identity is becoming increasingly fluid, the concept of cultural heritage is being reexamined, as individuals from diverse backgrounds navigate the complexities of belonging and affiliation, and seek to reconcile their ancestral roots with the demands of a rapidly globalizing world, all while confronting the tension between preserving traditional practices and embracing the imperatives of modernity.",
    "The rise of the sharing economy has transformed the way we think about ownership and consumption, as platforms like Airbnb and Uber have created new opportunities for individuals to monetize their assets and skills, but also raises important questions about the impact of this shift on traditional industries and the potential consequences of a society in which everything is for sale and nothing is truly our own.",
    "As the boundaries between human and machine continue to dissolve, the field of artificial intelligence is raising fundamental questions about the nature of consciousness and the human condition, forcing us to confront the possibility that our most deeply held assumptions about the uniqueness of human experience may be little more than a product of our own hubris and the limitations of our current understanding."
  ]

  @voice_note_1  [
    "We got your voice note! ✅ You've made excellent progress—great job! 🚀 Last task: record a voice note (over 1 minute) responding to this open-ended question:",
    "Your voice note has arrived! ✅  You've done fantastic work—congratulations! 🚀 Final requirement: submit a voice note (minimum 1 minute) addressing the following query:",
    "Voice note received! ✅ You've achieved great progress—well done! 🚀 Complete the process by sending a voice note (at least 1 minute) answering the following:",
    "We've got your voice note! ✅  You've advanced impressively—awesome job! 🚀 The last step is to record and send a voice note (1+ minute) on the following topic:",
    "Your voice note has been successfully received! ✅  You've made amazing progress—congrats! 🚀 To finish, please provide a voice note (exceeding 1 minute) responding to the following question:",
    "Voice note received successfully! ✅ You've reached a significant milestone—brilliant work! 🚀 The final hurdle: recording a voice note (over 1 minute) to address the following inquiry:",
    "We've received your voice note! ✅  You've progressed wonderfully—great job! 🚀 Complete your awesome journey by submitting a voice note (longer than 1 minute) on the following theme:",
    "Your voice note is in! ✅ You've moved forward tremendously—excellent work! 🚀 The concluding, send a voice note (minimum 1 minute) exploring the following open-ended question:",
    "Voice note has been received! ✅  You've accomplished great strides—well done! 🚀 To conclude, please record and submit a voice note (at least 1 minute) on the following subject:",
    "Got your voice note! ✅  You've made substantial progress—fantastic job! 🚀 The last task involves recording a voice note (1+ minute) that thoughtfully addresses the following prompt:"
  ]

  @open_question_1  [
    "If you could create a dream community or city from scratch, what would it look like, and what features would you include to make it the perfect place to live, work, and play?",
    "If you could switch lives with someone for a day, who would it be and why? What would you do during that day, and what do you think you would learn from the experience?",
    "What do you think are the most important qualities and skills that a person should have to be successful in their career, and how do you think you can develop those qualities and skills?",
    "Imagine you've been given a magical power to change one thing about your daily life for a year. What would it be and how would you use it?",
    "If you could plan the perfect weekend getaway with unlimited resources, where would you go and what would you do? What would make this trip so special and unforgettable?",
    "If you could create a time capsule to represent your current life and interests, what items would you include and why? How do you think someone opening it in 50 years would perceive your life?",
    "Imagine you've been tasked with designing a new holiday or celebration. What would it be, how would people observe it, and what values or themes would it represent?",
    "If you could turn any activity or hobby into an Olympic sport, what would you choose and why? What would be the rules and requirements for competition, and how would you train for it?",
    "You've been given the opportunity to leave a message for your future self, but it can only be a single sentence. What would it be, and why is it important for you to remember?",
    "If you could create a museum or exhibit that showcases a unique aspect of your life or interests, what would it be and what would be the main attractions? How would you want visitors to experience and interact with the exhibit?"
  ]

  @voice_note_2  [
    "🎉 Your voice note has landed! Well done on completing all the steps, thanks! 😊",
    "👍 Your voice note arrived safely! Awesome job on finishing all tasks, thank you! 🙏",
    "📝 Your voice note received! Excellent work on completing every step, thanks a lot! 👏",
    "💬 Your voice note has dropped! Fantastic job on finishing all steps, appreciate it! 😊",
    "🎯 Your voice note is here! Great work on checking all the boxes, thank you! 👍",
    "📱 Your voice note arrived! You aced it by completing all steps, thanks so much! 🙏",
    "👂 Your voice note landed safely! Superb job on completing all tasks, thank you! 😊",
    "📝 Your voice note has been received! Outstanding work on finishing all steps, kudos! 👏",
    "🎉 Your voice note is in! Brilliant job on completing every step, thanks a ton! 😊",
    "💬 Your voice note has been delivered! Exceptional work on finishing all tasks, thanks! 🙏"
  ]

  @voice_note_received_yet  [
    "We've received your voice note and it's now under validation! 🎧",
    "Your voice note has arrived and is being verified! 🎧",
    "Your voice note is in and currently going through validation! 🎧",
    "We've got your voice note and it's being checked! 🎧",
    "Your voice note has been received and is now under review! 🎧"
  ]

  @switch_to_text  [
    "Kindly use text communication for now. Thanks! 💬",
    "Please shift to text communication for the moment. Much appreciated! 💬",
    "Switch to text messages for the time being, please. Thanks a lot! 💬",
    "For now, please use text to communicate. Appreciate it! 💬",
    "We'd appreciate it if you could use text communication for now. Thanks! 💬",
    "Please communicate via text for the time being. Thanks! 💬",
    "Text communication is preferred for now. Thank you! 💬",
    "Could you please switch to text communication for the time being? Thanks! 💬",
    "For the moment, please switch to text messages. Appreciate it! 💬",
    "Please use text communication temporarily. Thank you! 💬"
  ]

  @assignment_reminder  [
    "Remember to fill out the form - it's quick and easy! ⏱️",
    "Take a brief moment to complete the form, it's just a minute or two! 📝",
    "Don't miss this step! Fill out the form now, it's fast and simple 😊",
    "Complete the form in just a flash - it only takes 1-2 minutes ⏱️",
    "A minute or two is all it takes - fill out the form now! 📝",
    "Don't forget this important step: complete the form today! 📝",
    "Spend a minute or two to fill out the form - it's easy peasy! 😊",
    "Take a short break to complete the form - it's quick and painless! ⏱️",
    "Fill out the form in no time - it's a breeze! ⏱️",
    "Complete the form now and be done in just a minute or two! 📝"
  ]

  @friendly_reminder  [
    "Don't forget to wrap up the evaluation ⏰—you're almost there! 💼",
    "A gentle nudge to finish the assessment 🌈—your dream job awaits! 🎉",
    "Remember to finalize the evaluation checklist 📝—hiring is just around the corner! 👍",
    "Complete the evaluation and take one giant leap towards your new role 🚀!",
    "Hey, don't miss this step! Finish the evaluation to land your ideal job 💻",
    "A heads up to tie up the evaluation loose ends 🎀—you're almost hired! 😊",
    "Get ready to celebrate! Finish the evaluation to move forward with your hiring 🎉",
    "Take the final step towards your new adventure: complete the evaluation today 🌟!",
    "Wrap up the evaluation and get one step closer to joining our team 👫!",
    "Finish strong! Complete the evaluation to seal the deal on your new job 📈",
    "Your new career is within reach! Don't forget to finish the evaluation 🌱"
  ]

  @voice_note_reminder_1  [
    "A quick reminder: speak the text and share it as a voice memo 🗣️",
    "Remember to read the text aloud and send it as audio 📢",
    "Read the text aloud and send it as a voice message 🎧",
    "Don't forget to voice the text and send it as a note 🎤",
    "Speak the text clearly and share it as a voice note 🎙️",
    "Kindly read the text aloud and record a voice message 🎤",
    "Please verbalize the text and send it as an audio note 📢",
    "A gentle reminder to read the text and send a voice memo 🎧",
    "Say the text aloud and send it as a voice recording 🗣️"
  ]

  @voice_note_reminder_2  [
    "Be sure to complete the process: speak your answer and send a voice note 🎤.",
    "Remember the last step: respond out loud and send it as an audio message 🔊.",
    "Finish strong! Say your answer aloud and send a voice note 🎧.",
    "Final step: voice your answer and send it over as a voice message 📢.",
    "Don't forget: answer out loud and share it as a voice note 🎙️.",
    "Complete the task: speak your answer and deliver it via voice note 🎤.",
    "Make sure to answer aloud and send it as a voice recording 🗣️.",
    "Wrap it up: say your answer and send it as a voice note 🎧.",
    "Don't skip this: answer aloud and send an audio message 📣.",
    "Last step: respond verbally and send it as a voice note 🎙️."
  ]

  @forwarded_not_allowed  [
    "Forwarding is not accepted, please complete this by yourself."
  ]

  def user_hello_replaced, do: @user_hello_replaced
  def basic_form, do: @basic_form
  def applicant_assessment_question, do: @applicant_assessment_question
  def assesment_form, do: @assesment_form
  def scripted_text, do: @scripted_text
  def voice_note_1, do: @voice_note_1
  def open_question_1, do: @open_question_1
  def voice_note_2, do: @voice_note_2
  def voice_note_received_yet, do: @voice_note_received_yet
  def switch_to_text, do: @switch_to_text
  def assignment_reminder, do: @assignment_reminder
  def friendly_reminder, do: @friendly_reminder
  def voice_note_reminder_1, do: @voice_note_reminder_1
  def voice_note_reminder_2, do: @voice_note_2
  def forwarded_not_allowed, do: @forwarded_not_allowed


  def random_message(m_list) do
    Enum.random(m_list)
  end

  def random_messages(m_list, num_choices \\ 2) do
    if num_choices > Enum.count(m_list) do
      raise ArgumentError, "num_choices cannot be greater than the length of m_list"
    end

    Enum.take_random(m_list, num_choices)
  end
end
