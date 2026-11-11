# Arc user notes

Material the user has sent through /arc, "Add information" mode.
These notes win over patterns.md when they disagree.

Format: one heading per topic. Under it, short notes with the date and source.

## Three traps

Added 2026-11-11. Source: user, from the course.

Check for all three in every design and every audit.

1. Wrong problem. Ask what business problem is being solved. Ask if it can be solved without AI. If a plain script, rule or query works, say so first.
2. Anthropomorphising agents. Do not treat an agent like a person with judgment. The fix is to always start simple. Begin with the plainest design and add autonomy only when it is needed.
3. Plausible versus accurate. Model output can read well and still be wrong. Make sure outcomes are evaluated. Do not accept an answer because it sounds right.

## Subagents

Added 2026-11-11. Source: user, from the course.

Drive subagents by outcomes. Give each one the result to reach and what done looks like. Do not script its steps. In an audit, flag subagents that are briefed with steps and no outcome.

Why use subagents. Added 2026-11-11. Source: user, from the course.

1. Context isolation. Each subagent works in its own clean context. This gives more accurate results.
2. LLM as a judge. A separate model can check the work of another. See the next section.
3. Cost efficiency. Use the right model for the job.
4. Speed. Run lookups in parallel, for example research threads.
5. Security. Give each subagent focused permissions. This reduces risk.

## LLM as a judge

Added 2026-11-11. Source: user, with detail from https://en.wikipedia.org/wiki/LLM-as-a-Judge

A model scores or compares the output of another model against set criteria. It costs less than human review.

- Formats. A score, a label, or a pick between candidates. It can be reference-free or reference-based. Reference-based means a gold answer or a rubric is supplied.
- Position bias. The judge favours an answer by where it sits in the prompt. In a 2023 study GPT-4 gave the same verdict in both orders only about two thirds of the time.
- Verbosity bias. Longer answers win. In the same study Claude and GPT-3.5 preferred a padded rewrite over 90% of the time.
- Self-preference. A judge rates its own model family higher.
- Overconfidence. Judges show more confidence than their accuracy supports.
- Reproducibility. Scores change between runs. They also change when the API model changes.
- Accuracy. Agreement with humans varies by task. On JudgeBench, where one answer is objectively correct, judges including GPT-4o scored only slightly above chance.
- Fix for position. Run both orders. Count a win only if the same answer wins both times.
- Fix for noise. Take a majority vote over repeated runs. Use a panel of judges from different model families.
- Better prompts. Give a rubric and a reference answer. Ask for reasoning steps. Pairwise comparison tends to beat pointwise scoring.
- Before trusting a judge, check it against human labels. Keep humans in the loop to audit it.
- Audit flags. The judge is from the same model family as the generator. Pairwise runs use one order only. The judge was never checked against human labels.

## Evals

Added 2026-11-11. Source: user, from the course.

There are three main ways to check that an AI system gives accurate results.

1. Direct measurement. Run a test dataset with a golden truth, meaning known right answers. Or measure against real world outcomes.
2. LLM as a judge. A model scores the output. See the "LLM as a judge" section for the biases and fixes.
3. Human review. A person checks the output.

This is the answer to the "plausible versus accurate" trap. In an audit, note which of the three methods the system uses.

### Confusion matrix

Added 2026-11-11. Source: user, with detail from https://en.wikipedia.org/wiki/Confusion_matrix

A table that compares actual classes with predicted classes. Rows are usually actual and columns predicted. Some sources swap them. Correct answers sit on the diagonal. Anything off the diagonal shows which classes get mixed up.

- Four outcomes for a yes or no task. True positive, false negative, false positive, true negative.
- Totals. Positives P = TP + FN. Negatives N = FP + TN.
- Accuracy alone can mislead when the classes are unbalanced.
- Example. A set has 95 cancer cases and 5 healthy ones. A classifier that says "cancer" every time scores 95% accuracy. It gets 0% right on the healthy class.
- F1 also misleads there. It scores over 97.4% for that classifier.
- Informedness scores 0 for pure guessing.
- Chicco and Jurman call the Matthews correlation coefficient (MCC) the most informative single metric.
- It works for more than two classes. It also has extensions for multi-label tasks.
- Limit. It cannot show if a right answer came from sound reasoning or from luck. It cannot show when the facts change later. It can give an incomplete picture of reliability.
- Use it with direct measurement on a test dataset with a golden truth. Good fits are classifiers, routers and triage steps.
- Audit flag. A classifying step is judged on accuracy alone and its classes are unbalanced.
