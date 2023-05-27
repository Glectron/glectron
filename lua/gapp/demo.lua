-- temporary workaround since we dont have packaging tool for now
APP.__html_source__ = [[
    <body style="display: none;">
        <h1>Hi, this is a glectron app</h1>
        <p>Currently we don't have Glectron UI library, so the app cannot be easily developed like a vgui app.</p>
        <p>Also we cannot handle the mouse/keyboard event passthroughing correctly, this is why this minimal concept shouldn't be used.</p>
        <script>
            addEventListener("setup", () => {
                document.body.style.display = "";

                test("123", 456, function(func) {
                    console.log("called back");
                    func("foobar");
                });
            });
        </script>
    </body>
]]

local function call_me_again(arg)
    print("me being called with arg " .. arg)
end

function APP:Setup()
    self:RegisterLuaFunction("test", function(print1, print2, fn)
        print(print1)
        print(print2)
        fn(call_me_again)
    end)
end