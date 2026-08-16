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
      { type = "required_linear_history"; }
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

  # Separate from the ruleset: repo-wide merge-button settings (a different API).
  # No merge commits (enforced again, redundantly but harmlessly, by
  # required_linear_history above); squash and rebase both stay available.
  # allow_update_branch=true makes the "Update branch" button appear on
  # out-of-date PRs, defaulting to rebase once linear history is required.
  repoSettings = {
    allow_merge_commit = false;
    allow_squash_merge = true;
    allow_rebase_merge = true;
    allow_update_branch = true;
  };
in
{
  perSystem =
    { pkgs, ... }:
    let
      rulesetFile = pkgs.writeText "main-ruleset.json" (builtins.toJSON ruleset);
      repoSettingsFile = pkgs.writeText "repo-settings.json" (builtins.toJSON repoSettings);
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

          echo "Applying repo merge-button settings (no merge commits; squash/rebase only)..."
          gh api "repos/$repo" -X PATCH --input ${repoSettingsFile}
        '';
      };
    };
}
