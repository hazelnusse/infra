let
  ruleset = {
    name = "main-protection";
    target = "branch";
    enforcement = "active";
    conditions.ref_name = {
      include = [ "~DEFAULT_BRANCH" ];
      exclude = [ ];
    };
    bypass_actors = [ ];
    rules = [
      { type = "deletion"; }
      { type = "non_fast_forward"; }
      {
        type = "pull_request";
        parameters = {
          required_approving_review_count = 0;
          dismiss_stale_reviews_on_push = false;
          require_code_owner_review = false;
          require_last_push_approval = false;
          required_review_thread_resolution = false;
        };
      }
      {
        type = "required_status_checks";
        parameters = {
          required_status_checks = [ { context = "flake-check"; } ];
          strict_required_status_checks_policy = true;
        };
      }
    ];
  };
in
{
  perSystem =
    { pkgs, ... }:
    let
      rulesetFile = pkgs.writeText "main-ruleset.json" (builtins.toJSON ruleset);
    in
    {
      packages.apply-branch-ruleset = pkgs.writeShellApplication {
        name = "apply-branch-ruleset";
        runtimeInputs = [ pkgs.gh ];
        text = ''
          repo="hazelnusse/infra"
          existing_id=$(gh api "repos/$repo/rulesets" --jq '.[] | select(.name == "main-protection") | .id')
          if [ -n "$existing_id" ]; then
            echo "Updating existing ruleset (id: $existing_id)..."
            gh api "repos/$repo/rulesets/$existing_id" -X PUT --input ${rulesetFile}
          else
            echo "Creating new ruleset..."
            gh api "repos/$repo/rulesets" -X POST --input ${rulesetFile}
          fi
        '';
      };
    };
}
