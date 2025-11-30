{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Lau5er";
      user.email = "lau5er@icloud.com";
      core = {
        autocrlf = "input";
      };
    };
  };
}
