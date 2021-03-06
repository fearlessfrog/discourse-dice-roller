# name: dice_roller
# about: allows in-post dice rolling, for play-by-post RPGs
# version: 2
# authors: dorthu
# url: https://github.com/Dorthu/discourse-dice-roller

after_initialize do

    def roll_dice(type, user)
        num, size = type.match(/([1-9]*)d([0-9]+)/i).captures

        result = ''
        sum = 0

        if num.nil? or num.empty?
            num = 1
        else
            num = num.to_i
        end

        (1..num).each do |n|
            roll = rand(1..size.to_i)
            result += "+ #{roll} "
            sum += roll
        end

        if num == 1
            "@#{user.username} rolled `d#{size}:" + result[1..-1] + "`"
        elsif SiteSetting.dice_roller_sum_rolls
            if num > 9
              "Nope. Buy @wheelsup_cavu a beer though for finding the over 9 dice bug."
            else
              "@#{user.username} rolled `#{num}d#{size}:" + result[1..-1] + "= #{sum}`"
            end
        else
            "@#{user.username} rolled `#{num}d#{size}:" + result[1..-1] + "`"
        end
    end

    def inline_roll(post)
        post.raw.gsub!(/\[ ?roll *([1-9]*d[0-9]+) *\]/i) { |c| roll_dice(c, post.user) }
        # Hardcoded to dicebot user, nice..
        post.set_owner(User.find(470), post.user)
        #post.set_owner(User.find(-1), post.user)
    end

    def append_roll(post)
        puts '',"TODO - append rolled dice by the dice_roller_append_user"
    end

    on(:post_created) do |post, params|
        if SiteSetting.dice_roller_enabled and post.raw =~ /\[ ?roll *([1-9]*d[0-9]+) *\]/i
            if SiteSetting.dice_roller_inline_rolls
                inline_roll(post)
            else
                append_roll(post)
            end
            post.save
        end
    end
end
