import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const Hypnoconsole = (props, context) => {
  const { act, data } = useBackend(context);
  // Extract `health` and `color` variables from the `data` object.
  const {
    unlocked,
    brainwash_objective,
  } = data;
  return (
    <Window>
      <Window.Content scrollable>
        <Section title="Hypnosis Console">
          <Button
            content="The objective is... is...{brainwash_objective}"
            onClick={() => act('test')} />
        </Section>
      </Window.Content>
    </Window>
  );
};
